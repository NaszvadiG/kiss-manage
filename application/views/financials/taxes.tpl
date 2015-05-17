{% extends "wrapper.tpl" %}
{% block content %}
<br>
<div class="row">
    <div class="col-md-12">
        <div class="panel panel-primary">
            <div class="panel-heading">
               <b>Manage Taxes</b>
            </div>
            <div class="panel-body">
                <div class="well" style="padding-bottom: 3px;">
                    <h4>{{ selected.id ? 'Update' : 'Add' }} Tax Entry</h4>
                    <form role="form" id="edit_tax_form" method="POST" action="/financials/setTax">
                        <input type="hidden" name="id" value="{{ selected.id|default('0') }}">
                        <div class="table-responsive container-fluid">
                            <table class="table" id="taxes-edit-table">
                                <thead>
                                    <tr>
                                        <th>Check #</th>
                                        <th>Date</th>
                                        <th>Category</th>
                                        <th>Total</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td style="width: 130px;">
                                            <input class="form-control" style="width: 100px;" type="text" name="tax[check_num]" placeholder="#111" value="{{ selected.check_num }}">
                                        </td>
                                        <td style="width: 130px;">
                                            <input id="paid_date" class="form-control" style="width: 100px;" type="text" name="tax[paid_date]" value="{{ selected.paid_date }}" data-validation="required" data-validation-error-msg="Paid date required">
                                        </td>
                                        <td style="width: 200px;">
                                            <select class="form-control" name="tax[category_id]">
                                                {% for option in category_options %}
                                                {{ option|raw }}
                                                {% endfor %}
                                            </select>
                                        </td>
                                        <td style="width: 100px;">
                                            <input class="form-control" type="text" name="tax[total]" placeholder="0.00" value="{{ selected.total }}" data-validation="number" data-validation-allowing="float" data-validation-error-msg="Total required">
                                        </td>
                                    <tr>
                                    <tr>
                                        <td colspan="7" style="text-align: left">
                                            <button type="submit" class="btn btn-primary">Save</button>&nbsp;
                                            <button type="button" class="btn btn-default" id="clear_button">Clear</button>&nbsp;
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </form>
                </div>
                <div class="row">
                <div class="col-md-4">
                <form role="form" id="filter_date_form" method="POST" action="/financials/taxes">
                    <div class="form-group table-responsive container-fluid">
                        <table class="table ">
                            <thead>
                                <tr>
                                    <th>Filter By Paid Date</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>
                                         <input id="start_date" class="form-control" type="text" name="start_date" style="width: 100px;" value="{{ start_date }}" onchange="this.form.submit()">
                                    </td>
                                </tr>
                            </tbody>
                        </table>      
                    </div>
                </form>
                </div>
                </div>
                {% if not taxes %}
                <p align="center">No Taxes found</p>
                {% else %}
                <div class="dataTable_wrapper table-responsive container-fluid">
                    <table class="table table-striped table-bordered table-hover" id="taxes-list-table">
                        <thead>
                            <tr>
                                <th>&nbsp;</th>
                                <th>Check #</th>
                                <th>Date</th>
                                <th>Category</th>
                                <th>Total</th>
                            </tr>
                        </thead>
                        <tbody>
                        {% for tax in taxes %}
                        <tr>
                            <td style="vertical-align: middle; text-align: right; width: 30px;">
                                <a class="btn btn-primary btn-circle fa fa-pencil" href="/financials/taxes/{{ tax.id }}"></a>&nbsp;
                                <a class="btn btn-danger btn-circle fa fa-times delete_tax" tax_id="{{ tax.id }}"></a>
                            </td>
                            <td style="vertical-align: middle; width: 100px;">{{ tax.check_num }}</td>
                            <td style="vertical-align: middle; width: 100px;" class="paid_date">{{ tax.paid_date }}</td>
                            <td style="vertical-align: middle;" class="category">{{ tax.category }}</td>
                            <td style="vertical-align: middle; width: 100px; text-align: right;">${{ tax.total|number_format(2) }}</td>
                        </tr>
                        {% endfor %}
                        </tbody>
                        <tfoot>
                            <tr>
                                <th colspan="4" style="text-align:right">Totals: </th>
                                <th style="text-align:right"></th>
                            </tr>
                        </tfoot>
                    </table>
                </div>
                <form id="delete_tax_form" method="POST" action="/financials/deleteTax">
                    <input id="delete_tax_id" type="hidden" name="tax_id" value="">
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
    $('#taxes-list-table').DataTable({
            "responsive": true,
            "pageLength": 25,
            "searching": true,
            "stateSave": true,
            "bLengthChange": false,
            'aoColumnDefs': [{
                'bSortable': false,
                'aTargets': [0]
            }],
            "order": [[ 2, "desc" ]],
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
                    .column(4)
                    .data()
                    .reduce(function (a, b) {
                        return parseVal(a) + parseVal(b);
                    } );
                // Total over this page
                page_total = api
                    .column(4, {page: 'current'})
                    .data()
                    .reduce(function (a, b) {
                        return parseVal(a) + parseVal(b);
                    }, 0 );
                // Update footer
                var page_total_disp = $('<span>');
                var total_disp = $('<span>');
                page_total_disp.money(page_total);
                total_disp.money(total);
                $(api.column(4).footer()).html(page_total_disp.html()+' ('+total_disp.html()+')');
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
    $("#paid_date").datepicker({
        dateFormat: "yy-mm-dd",
    });
    $("#clear_button").click(function(){
        $("#filter_date_form").submit();
    });
    $(".delete_tax").click(function(){
        var tax_id = $(this).attr('tax_id');
        $("#delete_tax_id").val(tax_id);
        var paid_date = $(this).closest('tr').find('.paid_date').html();
        var category = $(this).closest('tr').find('.category').html();
        var check = "Are you sure you want to delete this tax entry: " + category + " - " + paid_date;
        $("#modal_body").html(check);
        $('#kiss_modal').modal('show');
    });
    $("#kiss_modal_confirm").click(function(event){
        $('#kiss_modal').modal('hide');
        $("#delete_tax_form").submit();
    });
});
</script>
{% endblock %}