{% extends "wrapper.tpl" %}
{% block content %}
<div class="row">
    <div class="col-md-4">
        <div class="panel panel-primary">
            <div class="panel-heading">
               <b>{{ action }} Invoice</b>
            </div>
            <div class="panel-body">
                <form role="form" id="set_time" method="POST" action="/business/setInvoice">
                    <input type="hidden" name="invoice[id]" value="{{ invoice.id|default('0') }}">
                    <div class="form-group">
                        <label>Invoice Date</label>
                        <input id="created_date" class="form-control" placeholder="Select Date" type="text" name="invoice[created_date]" style="width: 100px;" value="{{ invoice.created_date }}">
                    </div>
                    {% if action == 'Add' %}
                    <div class="form-group">
                        <label>Start Date</label>
                        <input id="start_date" class="form-control" placeholder="Select Date" type="text" name="start_date" style="width: 100px;" value="">
                    </div>
                    <div class="form-group">
                        <label>End Date</label>
                        <input id="end_date" class="form-control" placeholder="Select Date" type="text" name="end_date" style="width: 100px;" value="">
                    </div>
                    <script>
                    $(document).ready(function() {
                        $("#start_date").datepicker({
                            dateFormat: "yy-mm-dd",
                        });
                        $("#end_date").datepicker({
                            dateFormat: "yy-mm-dd",
                        });
                    });
                    </script>
                    <div class="form-group">
                        <label>Client</label>
                        <select class="form-control" name="invoice[client_id]" style="width:300px;">
                            <option value="0">-Select Client-</option>
                            {% for option in client_options %}
                            {{ option|raw }}
                            {% endfor %}
                        </select>
                    </div>
                    {% endif %}
                    {% if action == 'Update' %}
                    <div class="form-group">
                        <label>Client</label>
                        <select class="form-control" name="invoice[client_id]" style="width:300px;" disabled>
                            {% for option in client_options %}
                            {{ option|raw }}
                            {% endfor %}
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Amount</label>
                        <input disabled class="form-control" style="width: 100px;" type="text" name="invoice[amount]" value="{{ invoice.amount }}">
                    </div>
                    {% endif %}
                    <div class="form-group">
                        <div class="checkbox">
                            <label>
                                <input type="checkbox" name="invoice[paid]" value="1" {{ invoice.paid ? 'checked' : '' }}> Paid?
                            </label>
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Notes</label>
                        <textarea class="form-control" rows="2" cols="5" placeholder="Enter Notes" name="invoice[notes]">{{ invoice.notes }}</textarea>
                    </div>
                    <div class="form-group">
                        <button type="submit" class="btn btn-primary"> {{ action }} </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    {% if invoice_markup %}
    <div class="col-md-8">
        <div class="panel panel-primary">
            <div class="panel-heading">
               <b>Preview Invoice</b>
            </div>
            <div class="panel-body">
                <div class="row">
                    <div class="col-md-2 col-md-offset-10">
                        <a class="btn btn-success fa fa-save" href="/business/printInvoice/{{ invoice.id }}/1"></a>
                        <a class="btn btn-warning fa fa-envelope-o" href="/business/sendInvoice/{{invoice.id }}"></a>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-12" >
                        {{ invoice_markup|raw }}
                    </div>
                </div>
            </div>
        </div>
    </div>
    {% endif %}
</div>
<script>
$(document).ready(function() {
    $("#created_date").datepicker({
        dateFormat: "yy-mm-dd",
    });
});
</script>
{% endblock %}