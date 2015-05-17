{% extends "wrapper.tpl" %}
{% block content %}
{% if client.id %}
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
                <form role="form" id="set_time" method="POST" action="/manage/setClient">
                    <input type="hidden" name="client[id]" value="{{ client.id|default('0') }}">
                    <div class="form-group">
                        <label>Name</label>
                        <input class="form-control" placeholder="Enter Client Name" type="text" name="client[name]" value="{{ client.name }}" data-validation="required" data-validation-error-msg="You must provide a client name">
                    </div>
                    <div class="form-group">
                        <label>Address</label>
                        <textarea class="form-control" rows="3" placeholder="Enter Client Address" name="client[address]">{{ client.address }}</textarea>
                    </div>
                    <div class="form-group">
                        <label>Billing Emails</label>
                        <textarea class="form-control" rows="3" placeholder="Enter Billing Emails" name="client[billing_emails]">{{ client.billing_emails }}</textarea>
                    </div>
                    <div class="form-group">
                        <label>Default Rate</label>
                        <input class="form-control" style="width: 150px;" placeholder="Enter Default Rate" type="text" name="client[default_rate]" value="{{ client.default_rate }}">
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