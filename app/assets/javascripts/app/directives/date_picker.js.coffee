window.app
  .directive 'mykDatePicker', ->
    restrict: 'C'
    link:     (scope, ele) ->
      ele.datepicker
        format: "yyyy-mm-dd"
