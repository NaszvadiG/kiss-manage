{% extends "wrapper.tpl" %}
{% block content %}
{% if option.name %}
    {% set action = 'Update' %}
{% else %}
    {% set action = 'Add' %}
{% endif %}
<div class="row">
    <div class="col-md-6">
        <div class="panel panel-primary">
            <div class="panel-heading">
               <b>{{ heading }}</b>
            </div>
            <div class="panel-body">
                <form role="form" id="set_time" method="POST" action="/manage/setConfig">
                <input type="hidden" name="option[start_name]" value="{{ option.name }}">
                    <div class="form-group">
                        <label>Option Name</label>
                        <input class="form-control" placeholder="Enter Option Name" type="text" name="option[name]" value="{{ option.name }}" data-validation="custom" data-validation-regexp="^(\w+)$" data-validation-error-msg="You must provide an option name containing only letters, numbers, and underscores.">
                    </div>
                    <div class="form-group">
                        <label>Option Value</label>
                        <textarea class="form-control" placeholder="Enter Option Value" name="option[value]" style="height: 100px;">{{ option.value }}</textarea>
                    </div>
                    <div class="form-group">
                        <button type="submit" class="btn btn-primary"> {{ action }} </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
<script>
$(document).ready(function() {
    $.validate({
        onError : function() {
            return false;
        }
    });
});
</script>
{% endblock %}