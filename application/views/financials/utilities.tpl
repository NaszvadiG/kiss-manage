{% extends "wrapper.tpl" %}
{% block content %}
<br>
<div class="row">
    <div class="col-md-12">
        <div class="panel panel-primary">
            <div class="panel-heading">
               <b>Manage Utilities</b>
            </div>
            <div class="panel-body">
                <div class="well" style="padding-bottom: 3px;">
                    <h4>{{ selected.id ? 'Update' : 'Add' }} utility</h4>
                    <form role="form" id="edit_utility_form" method="POST" action="/financials/setutility">
                        <input type="hidden" name="id" value="{{ selected.id|default('0') }}">
                        <div class=" table-responsive container-fluid">
                            <table class="table" id="utilities-edit-table">
                                <thead>
                                    <tr>
                                        <th>Check #</th>
                                        <th>Paid Date</th>
                                        <th>Billing Date</th>
                                        <th>Service From</th>
                                        <th>Service To</th>
                                        <th>Category</th>
                                        <th>Total</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td>
                                            <input class="form-control" type="text" name="utility[check_num]" placeholder="#111" value="{{ selected.check_num }}">
                                        </td>
                                        <td>
                                            <input id="paid_date" class="form-control" type="text" name="utility[paid_date]" value="{{ selected.paid_date }}" data-validation="required" data-validation-error-msg="Paid date required">
                                        </td>
                                        <td>
                                            <input id="billing_date" class="form-control" type="text" name="utility[billing_date]" value="{{ selected.billing_date }}" data-validation="required" data-validation-error-msg="Billing date required">
                                        </td>
                                        <td>
                                            <input id="service_from" class="form-control" type="text" name="utility[service_from]" value="{{ selected.service_from }}">
                                        </td>
                                        <td>
                                            <input id="service_to" class="form-control" type="text" name="utility[service_to]" value="{{ selected.service_to }}">
                                        </td>
                                        <td>
                                            <select class="form-control" name="utility[category_id]">
                                                <option value="0">- Select -</option>
                                                {% for option in category_options %}
                                                {{ option|raw }}
                                                {% endfor %}
                                            </select>
                                        </td>
                                        <td>
                                            <input class="form-control" type="text" name="utility[total]" placeholder="0.00" value="{{ selected.total }}" data-validation="number" data-validation-allowing="float" data-validation-error-msg="Total required">
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
                <form role="form" id="filter_date_form" method="POST" action="/financials/utilities">
                    <div class="form-group container-fluid">
                        <label>Filter By Paid Date&nbsp;</label>
                        <input id="start_date" class="form-control" type="text" name="start_date" style="width: 100px;" value="{{ start_date }}" onchange="this.form.submit()">
                    </div>
                </form>
                {% if not utilities %}
                <p align="center">No utilities found</p>
                {% else %}
                <div class="dataTable_wrapper table-responsive container-fluid">
                    <table class="table table-striped table-bordered table-hover" id="utilities-list-table">
                        <thead>
                            <tr>
                                <th>&nbsp;</th>
                                <th>Check #</th>
                                <th>Paid Date</th>
                                <th>Billing Date</th>
                                <th>Service From</th>
                                <th>Service To</th>
                                <th>Category</th>
                                <th>Total</th>
                            </tr>
                        </thead>
                        <tbody>
                        {% for utility in utilities %}
                        <tr>
                            <td style="vertical-align: middle; width: 30px;">
                                <a class="btn btn-primary btn-circle fa fa-pencil" href="/financials/utilities/{{ utility.id }}"></a>&nbsp;
                                <a class="btn btn-danger btn-circle fa fa-times delete_utility" utility_id="{{ utility.id }}"></a>
                            </td>
                            <td style="vertical-align: middle;">{{ utility.check_num }}</td>
                            <td style="vertical-align: middle;" class="utility_paid_date">{{ utility.paid_date }}</td>
                            <td style="vertical-align: middle;">{{ utility.billing_date }}</td>
                            <td style="vertical-align: middle;">{{ utility.service_from }}</td>
                            <td style="vertical-align: middle;">{{ utility.service_to }}</td>
                            <td style="vertical-align: middle;" class="utility_category">{{ utility.category }}</td>
                            <td style="vertical-align: middle; text-align: right;">${{ utility.total|number_format(2) }}</td>
                        </tr>
                        {% endfor %}
                        </tbody>
                        <tfoot>
                            <tr>
                                <th colspan="6" style="text-align:right">Totals: </th>
                                <th colspan="2" style="text-align:right"></th>
                            </tr>
                        </tfoot>
                    </table>
                </div>
                <form id="delete_utility_form" method="POST" action="/financials/deleteUtility">
                    <input id="delete_utility_id" type="hidden" name="utility_id" value="">
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
    $('#utilities-list-table').DataTable({
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
                    .column(7)
                    .data()
                    .reduce(function (a, b) {
                        return parseVal(a) + parseVal(b);
                    } );
                // Total over this page
                page_total = api
                    .column(7, {page: 'current'})
                    .data()
                    .reduce(function (a, b) {
                        return parseVal(a) + parseVal(b);
                    }, 0 );
                // Update footer
                var page_total_disp = $('<span>');
                var total_disp = $('<span>');
                page_total_disp.money(page_total);
                total_disp.money(total);
                $(api.column(6).footer()).html(page_total_disp.html()+' ('+total_disp.html()+')');
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
    $("#billing_date").datepicker({
        dateFormat: "yy-mm-dd",
    });
    $("#service_from").datepicker({
        dateFormat: "yy-mm-dd",
    });
    $("#service_to").datepicker({
        dateFormat: "yy-mm-dd",
    });
    $("#clear_button").click(function(){
        $("#filter_date_form").submit();
    });
    $(".delete_utility").click(function(){
        var utility_id = $(this).attr('utility_id');
        $("#delete_utility_id").val(utility_id);
        var paid_date = $(this).closest('tr').find('.utility_paid_date').html();
        var category = $(this).closest('tr').find('.utility_category').html();
        var check = "Are you sure you want to delete this utility: " + category + " - " + paid_date;
        $("#modal_body").html(check);
        $('#kiss_modal').modal('show');
    });
    $("#kiss_modal_confirm").click(function(event){
        $('#kiss_modal').modal('hide');
        $("#delete_utility_form").submit();
    });
});
</script>
{% endblock %}