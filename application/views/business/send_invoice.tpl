{% extends "wrapper.tpl" %}
{% block content %}
<div class="row">
    <div class="col-md-6">
        <div class="panel panel-primary">
            <div class="panel-heading">
               <b>Send Invoice</b>
            </div>
            <div class="panel-body">
                <form role="form" id="set_time" method="POST" action="/business/doSendInvoice">
                    <div class="form-group">
                        <label>Invoice ID</label>
                        <input disabled id="invoice_id" class="form-control" type="text" name="message[invoice_id]" style="width: 100px;" value="{{ invoice.id }}">
                    </div>
                    <div class="form-group">
                        <label>Invoice Date</label>
                        <input disabled id="created_date" class="form-control" type="text" name="message[created_date]" style="width: 100px;" value="{{ invoice.created_date }}">
                    </div>
                    <div class="form-group">
                        <label>Amount</label>
                        <input disabled class="form-control" style="width: 100px;" type="text" name="message[amount]" value="${{ invoice.amount }}">
                    </div>
                    <div class="form-group">
                        <label>Email Recipients</label>
                        <textarea class="form-control" rows="4" cols="5" placeholder="Enter Recipients" name="message[recipients]">{{ client.billing_emails }}</textarea>
                    </div>
                    <div class="form-group">
                        <label>Include Message in Email</label>
                        <textarea class="form-control" rows="4" cols="4" placeholder="Enter Message" name="message[message]">{{invoice.notes}}</textarea>
                    </div>
                    <div class="form-group">
                        <button type="submit" class="btn btn-primary">Send Invoice</button>
                    </div>
                    <input type="hidden" name="message[invoice_id]" value="{{ invoice.id }}">
                    <input type="hidden" name="message[created_date]" value="{{ invoice.created_date }}">
                    <input type="hidden" name="message[amount]" value="{{ invoice.amount }}">
                </form>
            </div>
        </div>
    </div>
</div>
{% endblock %}
