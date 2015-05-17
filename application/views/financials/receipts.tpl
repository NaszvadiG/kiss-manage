{% extends "wrapper.tpl" %}
{% block content %}
<br>
<div class="row">
    <div class="col-md-12">
        <div class="panel panel-primary">
            <div class="panel-heading">
               <b>Manage Recepts</b>
            </div>
            <div class="panel-body">
                <div class="well" style="padding-bottom: 3px;">
                    <h4>{{ selected.id ? 'Update' : 'Add' }} Receipt</h4>
                    <form role="form" id="edit_receipt_form" method="POST" action="/financials/setReceipt">
                        <input type="hidden" name="id" value="{{ selected.id|default('0') }}">
                        <div class=" table-responsive container-fluid">
                            <table class="table" id="receipts-edit-table">
                                <thead>
                                    <tr>
                                        <th width="100px">Date</th>
                                        <th width="10%">Number</th>
                                        <th width="20%">Vendor</th>
                                        <th width="30%">Description</th>
                                        <th width="20%">Category</th>
                                        <th width="70px">Total</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td>
                                            <input id="receipt_date" class="form-control" type="text" name="receipt[receipt_date]" value="{{ selected.receipt_date }}" style="width: 100px;" data-validation="required" data-validation-error-msg="Date required">
                                        </td>
                                        <td>
                                            <input class="form-control" type="text" name="receipt[receipt_number]" value="{{ selected.receipt_number }}">
                                        </td>
                                        <td>
                                            <input class="form-control" type="text" name="receipt[vendor]" value="{{ selected.vendor }}" data-validation="required" data-validation-error-msg="Vendor Required">
                                        </td>
                                        <td>
                                            <input class="form-control" type="text" name="receipt[description]" value="{{ selected.description }}" data-validation="required" data-validation-error-msg="Description Required">
                                        </td>
                                        <td>
                                            <select class="form-control" name="receipt[category_id]">
                                                <option value="0">- None -</option>
                                                {% for option in category_options %}
                                                {{ option|raw }}
                                                {% endfor %}
                                            </select>
                                        </td>
                                        <td>
                                            <input class="form-control" type="text" name="receipt[total]" placeholder="0.00" value="{{ selected.total }}" style="width:70px;" data-validation="number" data-validation-allowing="float" data-validation-error-msg="Total required">
                                        </td>
                                    <tr>
                                    <tr>
                                        <td colspan="7" style="text-align: left">
                                            <button type="submit" class="btn btn-primary">Save</button>&nbsp;
                                            <button type="button" class="btn btn-default" id="clear_button">Clear</button>&nbsp;
                                            <button type="button" class="btn btn-default" id="download_template">Donwload Template</button>&nbsp;
                                            <button type="button" class="btn btn-default" id="import_csv">Import Data</button>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </form>
                    <form method="POST" id="import_form" enctype="multipart/form-data" action="/financials/importReceipts">
                        <input type="file" id="import_file" name="import_file" style="opacity:0; height:0px;width:0px;" />
                    </form>
                </div>
                <form role="form" id="filter_date_form" method="POST" action="/financials/receipts">
                    <div class="form-group container-fluid">
                        <label>Filter By Date&nbsp;</label>
                        <input id="start_date" class="form-control" placeholder="Select Date" type="text" name="start_date" style="width: 100px;" value="{{ start_date }}" onchange="this.form.submit()">
                    </div>
                </form>
                {% if not receipts %}
                <p align="center">No receipts found</p>
                {% else %}
                <div class="dataTable_wrapper table-responsive container-fluid">
                    <table class="table table-striped table-bordered table-hover" id="receipts-list-table">
                        <thead>
                            <tr>
                                <th>&nbsp;</th>
                                <th width="10%">Date</th>
                                <th width="8%">Num</th>
                                <th width="20%">Vendor</th>
                                <th width="40%">Description</th>
                                <th width="13%">Category</th>
                                <th width="8%">Total</th>
                            </tr>
                        </thead>
                        <tbody>
                        {% for receipt in receipts %}
                        <tr>
                            <td style="vertical-align: middle; width: 30px;">
                                <a class="btn btn-primary btn-circle fa fa-pencil" href="/financials/receipts/{{ receipt.id }}"></a>&nbsp;
                                <a class="btn btn-danger btn-circle fa fa-times delete_receipt" receipt_id="{{ receipt.id }}"></a>
                            </td>
                            <td style="vertical-align: middle;">{{ receipt.receipt_date }}</td>
                            <td style="vertical-align: middle;" class="receipt_number">{{ receipt.receipt_number }}</td>
                            <td style="vertical-align: middle;" class="vendor">{{ receipt.vendor }}</td>
                            <td style="vertical-align: middle;" class="description">{{ receipt.description }}</td>
                            <td style="vertical-align: middle;">{{ receipt.category }}</td>
                            <td style="vertical-align: middle; text-align: right;">${{ receipt.total|number_format(2) }}</td>
                        </tr>
                        {% endfor %}
                        </tbody>
                        <tfoot>
                            <tr>
                                <th colspan="5" style="text-align:right">Totals: </th>
                                <th colspan="2" style="text-align:right"></th>
                            </tr>
                        </tfoot>
                    </table>
                </div>
                <form id="delete_receipt_form" method="POST" action="/financials/deleteReceipt">
                    <input id="delete_receipt_id" type="hidden" name="receipt_id" value="">
                </form>
                {% endif %}
            </div>
        </div>
    </div>
</div>
{% include 'kiss_modal.tpl' %}
<script src="/jquery/money.jquery.js"></script>
<script>
$(document).ready(function() {
    $.validate({
        onError : function() {
            return false;
        }
    });
    $('#receipts-list-table').DataTable({
            "responsive": true,
            "pageLength": 25,
            "searching": true,
            "stateSave": true,
            "bLengthChange": false,
            'aoColumnDefs': [{
                'bSortable': false,
                'aTargets': [0]
            }],
            "order": [[ 1, "desc" ]],
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
                    .column(6)
                    .data()
                    .reduce(function (a, b) {
                        return parseVal(a) + parseVal(b);
                    } );
                // Total over this page
                page_total = api
                    .column(6, {page: 'current'})
                    .data()
                    .reduce(function (a, b) {
                        return parseVal(a) + parseVal(b);
                    }, 0 );
                // Update footer
                var page_total_disp = $('<span>');
                var total_disp = $('<span>');
                page_total_disp.money(page_total);
                total_disp.money(total);
                $(api.column(5).footer()).html(page_total_disp.html()+' ('+total_disp.html()+')');
            }
    });
    $("#start_date").datepicker({
        dateFormat: "yy-mm-dd",
        beforeShow: function (textbox, instance) {
            instance.dpDiv.css({
                    marginTop: (-textbox.offsetHeight) + 'px',
                    marginLeft: textbox.offsetWidth + 'px'
            });
        }
    });
    $("#receipt_date").datepicker({
        dateFormat: "yy-mm-dd",
    });
    $("#clear_button").click(function(){
        $("#filter_date_form").submit();
    });
    $(".delete_receipt").click(function(){
        var receipt_id = $(this).attr('receipt_id');
        $("#delete_receipt_id").val(receipt_id);
        var receipt_number = $(this).closest('tr').find('.receipt_number').html();
        var vendor = $(this).closest('tr').find('.vendor').html();
        var description = $(this).closest('tr').find('.description').html();
        var receipt = vendor + " - " + description;
        if(receipt_number) {
            receipt = receipt + " (" + receipt_number + ")";
        }
        $("#modal_body").html("Are you sure you want to delete this receipt: "+receipt);
        $('#kiss_modal').modal('show');
    });
    $("#kiss_modal_confirm").click(function(event){
        $('#kiss_modal').modal('hide');
        $("#delete_receipt_form").submit();
    });
    $("#import_csv").click(function(event){
        $("#import_file").click();
    });
    $('#import_file').bind('change', function() {
        $('#import_form').submit();
    });
    $("#download_template").click(function(event){
        var url = "/financials/getReceiptsTemplate";
        var iframe = $('<iframe />').attr('src', url).hide().appendTo('body');
    });
});
</script>
{% endblock %}