{% extends "wrapper.tpl" %}
{% block content %}
<br>
<div class="row">
    <div class="col-md-10">
        <a href="/business/editInvoice" class="btn btn-primary">Create Invoice</a>
    </div>
</div>
<br>
<div class="row">
    <div class="col-md-10">
        <div class="panel panel-primary">
            <div class="panel-heading">
               <b>Manage Invoices</b>
            </div>
            <div class="panel-body">
                <div class="dataTable_wrapper table-responsive container-fluid">
                    <table class="table table-bordered table-hover" id="manage-table">
                        <thead>
                            <tr>
                                <th>&nbsp;</th>
                                <th>Client Name</th>
                                <th>Date</th>
                                <th>Amount</th>
                            </tr>
                        </thead>
                        <tbody>
                            {% for id, row in invoices %}
                            <tr class="{{ row.paid ? 'success' : 'danger' }}">
                                <td style="width: 100px; text-align: right;">
                                    {% if row.paid == 0 %}
                                    <a class="btn btn-success btn-circle fa fa-check set_paid" paid_id="{{ id }}"></a>&nbsp;
                                    {% endif %}
                                    <a class="btn btn-primary btn-circle fa fa-edit" href="/business/editInvoice/{{ id }}"></a>
                                    <a class="btn btn-danger btn-circle fa fa-times delete_invoice" invoice_id="{{ id }}"></a>
                                </td>
                                <td class="client_name">{{ row.client_name }}</td>
                                <td>{{ row.created_date }}</td>
                                <td style="text-align: right;">${{ row.amount|number_format(2) }}</td>
                            </tr>
                            {% endfor %}
                        </tbody>
                        <tfoot>
                            <tr>
                                <th colspan="2" style="text-align:right"></th>
                                <th colspan="2" style="text-align: right;"></th>
                            </tr>
                        </tfoot>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
<div class="modal fade" id="set_paid_modal" tabindex="-1" role="dialog" aria-labelledby="set_paid_modal_label" aria-hidden="true" data-backdrop="false">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <h4 class="modal-title" id="set_paid_modal_label"></h4>
            </div>
            <div class="modal-body" id="set_paid_modal_body">
                <form role="form" id="set_paid_form" method="POST" action="/business/setInvoicePaid">
                    <input type="hidden" name="paid[id]" id="set_paid_id" value="">
                    <div class="form-group">
                        <label>Paid Date</label>
                        <input id="set_paid_date" class="form-control" placeholder="Select Date" type="text" name="paid[paid_date]" style="width: 100px;" value="">
                    </div>
                    <div class="form-group">
                        <label>Check #</label>
                        <input id="set_paid_check" class="form-control" placeholder="1234" type="text" name="paid[check_num]" style="width: 100px;" value="">
                    </div>
                    <div class="form-group">
                        <label>Account</label>
                        <select class="form-control" name="paid[account_id]" style="width:250px;">
                            {% for option in account_dropdown %}
                            {{ option|raw }}
                            {% endfor %}
                        </select>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">No</button>
                <button type="button" class="btn btn-primary" id="set_paid_modal_confirm">Yes</button>
            </div>
        </div>
    </div>
</div>
<form id="delete_invoice_form" method="POST" action="/business/deleteInvoice">
    <input type="hidden" name="invoice_id" id="delete_invoice_id" value="0">
</form>
{% include 'kiss_modal.tpl' %}
<script src="/jquery/money.jquery.js"></script>
<script>
$(document).ready(function() {
    $('#manage-table').DataTable({
        "responsive": true,
        "pageLength": 25,
        "searching": true,
        "stateSave": true,
        "bLengthChange": false,
        'aoColumnDefs': [{
            'bSortable': false,
            'aTargets': [0]
        }],
        "order": [[2, "desc" ], [1, "asc"]],
        "footerCallback": function (row, data, start, end, display) {
            var api = this.api(), data;
            // Remove the formatting to get integer data for summation
            var parseVal = function (i) {
                if(typeof i === 'string') {
                    i = i.replace(/[\$,]/g, '');
                }
                return Number(i);
            };
            // Total over all pages
            total = api
                .column(3)
                .data()
                .reduce(function (a, b) {
                    return parseVal(a) + parseVal(b);
                } );
            // Total over this page
            page_total = api
                .column(3, {page: 'current'})
                .data()
                .reduce(function (a, b) {
                    return parseVal(a) + parseVal(b);
                }, 0 );
            // Update footer
            var page_total_disp = $('<span>');
            var total_disp = $('<span>');
            page_total_disp.money(page_total);
            total_disp.money(total);
            $(api.column(3).footer()).html("Totals:&nbsp;&nbsp;" + page_total_disp.html()+' ('+total_disp.html()+')');
        }
    });
    $(".delete_invoice").click(function(event){
        var invoice_id = $(this).attr('invoice_id');
        $("#delete_invoice_id").val(invoice_id);
        var client_name = $(this).closest('tr').find('.client_name').html();
        var check = "Are you sure you want to delete this invoice: " + invoice_id + " - " + client_name;
        $("#modal_body").html(check);
        $('#kiss_modal').modal('show');
    });
    $("#kiss_modal_confirm").click(function(event){
        $('#kiss_modal').modal('hide');
        $("#delete_invoice_form").submit();
    });
    $(".set_paid").click(function(event){
        var invoice_id = $(this).attr('paid_id');
        $("#set_paid_id").val(invoice_id);
        $("#set_paid_modal_label").html("Set Invoice #"+invoice_id+" Paid");
        $("#set_paid_date").datepicker({
            dateFormat: "yy-mm-dd"
        }).datepicker("setDate", new Date());
        $('#set_paid_modal').modal('show');
    });
    $("#set_paid_modal_confirm").click(function(event){
        $('#set_paid_modal').modal('hide');
        $("#set_paid_form").submit();
    });
});
</script>
{% endblock %}