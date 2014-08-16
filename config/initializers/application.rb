# system-wise global funcitons or settings
PER_PAGE = 15

# REGEXP_INTEGER_RANGE = /\A\d+(-\d+)?\z/
# REGEXP_RATE_HASH     = /\A(\s*\d+(\.\d*)?+\s*(-\s*\d+(\.\d*)?)?\s*:\s*(-)?\d+(,?\d{3})*(\.\d*)?\s*\/?)+\z/
# REGEXP_EMAIL_FORMAT  = /^[_a-z0-9-]+(\.+[_a-z0-9-]+)*@[_a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,4})$/i
# REGEXP_EXPIRE_DATE_FORMAT = /^(0[1-9]|1[0-2])(\d{2})$/

# override mailer settings
# begin
#   Devise.mailer_sender = ENV['MAIL_SENDER']
#   Rails.configuration.action_mailer.default_url_options = {host: ENV['MAIL_HOST']}

#   if Rails.env.production?
#     Rails.configuration.action_mailer.smtp_settings[:user_name] = ENV['SMTP_USERNAME']
#     Rails.configuration.action_mailer.smtp_settings[:password]  = ENV['SMTP_PASSWORD']
#   end
# rescue
#   raise 'mailer global config not found'
# end

# global settings
# begin
#   Rails.application.config.secret_key_base = ENV['SECRET_KEY']
#   Devise.secret_key = ENV['SECRET_KEY']
# rescue
#   Rails.logger.warn 'secret key not found'
# end

# global methods
#
def tmap(key = nil, code = nil, return_nil = false)
  if key.present?
    h = I18n.t(key, scope: 'sys_params', default: [[]], locale: :en)
    if code
      (h.find{ |r| r[1] == code } || [code])[0]
    else
      return_nil ? nil : h
    end
  else
    I18n.t('sys_params', locale: :en)
  end
end

def tmap_reverse(key, search_str)
  h = I18n.t(key, scope: 'sys_params', default: [[]], locale: :en)
  result = h.select{ |r| r[0].downcase.include?(search_str.downcase) }.map{ |r| r[1] }
  result = [search_str] if result.empty?
  result
end

def tmap_code(key = nil)
  key.present? ? tmap(key).map{ |r| r[1] || r[0] } : []
end

def tmap_code_from_hash_key(key = nil)
  if key.present?
    tmap(key).map{ |k, arr| arr }.map{ |arr_A| arr_A.map{ |arr_B| arr_B[1] } }.flatten
  else
    []
  end
end

def tmap_class_constants(key, prefix = '')
  tmap(key).each{ |r| const_set("#{prefix}#{r[0].gsub(/\s|-/, '_')}".upcase, r[1]) }
end

def tmap_class_query_methods(key, attr, attr_type = nil)
  if attr_type == Array
    tmap(key).each do |r|
      define_method("#{r[0].gsub(/\s|-/, '_').downcase}?") { send(attr.to_sym).try(:include?, r[1]) }
      scope :"#{r[0].gsub(/\s|-/, '_').downcase}", -> { where("#{table_name}.? = ANY(#{attr})", r[1]) }
    end
  else
    tmap(key).each do |r|
      define_method("#{r[0].gsub(/\s|-/, '_').downcase}?") { send(attr.to_sym) == r[1]  }
      scope :"#{r[0].gsub(/\s|-/, '_').downcase}", -> { where("#{table_name}.#{attr} = ?", r[1]) }
    end
  end
end

def random_reference_no(options = {})
  options.reverse_merge!(prepend_date: false, digits: 8)
  result = format("%0#{options[:digits]}d", SecureRandom.random_number(10**options[:digits]))
  (result = Date.today.strftime("%y%m%d") + '-' + result) if options[:prepend_date]
  result
end

def log_exception(exception)
  logger.error "\n#{exception.class.name}: #{exception}"
  logger.error exception.backtrace.select{ |_| _.include?(Rails.root.to_s) }.join("\n")
end

def dir_tree(path, format = 'build-dir')
  `tree.rb #{path} --format=#{format} -A 2>&1` if path
end

class String
  def lookup(key)
    tmap(key, self)
  end

  def reverse_lookup(key)
    tmap_reverse(key, self)
  end

  def parse_keyvalue_pair
    if match(/\A\s*(\d+|\d*\.\d*)\s*\Z/)
      Hash["1", $1]
    else
      Hash[scan(/\s*(\d+(?:\.\d+)?(?:-\d+(?:\.\d+)?)?)\s*:\s*(\*|\d+(?:\.\d+)?\*?)/)]
    end
  end
end

class Hash
  def total
    values.map{ |v| v.to_f }.sum
  end

  def deep_find(key)
    return self[key] if key?(key)

    values.each do |nested|
      found = nested.deep_find(key) if nested.is_a?(Hash)
      return found if found
    end
    nil
  end
end

class Date
  def months_diff(from, floor = true)
    m = (month - from.month) + 12 * (year - from.year)
    if floor
      m -= if mday < from.mday
             (m > 0 ? 1 : -1)
           else
             0
           end
    end
    m
  end

  def age(options = {})
    opts = {as_of: Date.today}.merge(options)

    as_of = opts[:as_of]

    return nil if as_of < self

    ages = as_of.year - year - (as_of.month > month || (as_of.month == month && as_of.day >= day) ? 0 : 1)
    ages += 1 if opts[:next]
    if opts[:nearest]
      ages += ((self + (ages + 1).years - as_of).to_i <= 183 ? 1 : 0)
    end

    ages
  end
end

class BigDecimal
  def round_unit(mode = :default)
    round(3, mode)
  end

  def round_amount(mode = :default)
    round(2, mode)
  end
end
