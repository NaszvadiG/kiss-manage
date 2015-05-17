{% extends "wrapper.tpl" %}
{% block content %}
<div class="row">
    <div class="col-md-12">
        <div class="panel panel-primary">
            <div class="panel-heading">
                <b>Time Tracking</b>
            </div>
            <div class="panel-body">
                <div class="row">
                    <div class="col-md-8">
                        <form role="form" id="set_time" method="POST" action="/business/setTime">
                        <input type="hidden" name="entry_id" value="{{ selected_entry.id|default('0') }}">
                        <div class="form-group">
                            <label>Entry Date</label>
                            <input id="entry_date" class="form-control" placeholder="Select Date" type="text" name="entry[entry_date]" style="width: 100px;" value="{{ selected_entry.entry_date|default('now'|date('Y-m-d')) }}">
                        </div>
                        <div class="form-group">
                            <label>Client</label>
                            <select class="form-control" name="entry[client_id]" style="width: 300px;">
                            {% for option in client_options %}
                            {{ option|raw }}
                            {% endfor %}
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Time</label>
                            <input id="total_time" class="form-control" placeholder="00:00" type="text" name="entry[total_time]" style="width: 100px;" value="{{ selected_entry.total_time }}">
                        </div>
                        <div class="form-group">
                            <label>Special Rate</label>
                            <input id="rate" class="form-control" placeholder="0.00" type="text" name="entry[rate]" style="width: 100px;" value="{{ selected_entry.rate }}">
                        </div>
                        <div class="form-group">
                            <label>Work Performed</label>
                            <textarea class="form-control" rows="6" placeholder="Enter Work Performed" name="entry[work_performed]">{{ selected_entry.work_performed }}</textarea>
                        </div>
                        <button type="submit" class="btn btn-primary">{{ selected_entry.id ? 'Update' : 'Add' }}</button>
                        </form>
                    </div>
                    <div class="col-md-2">
                        &nbsp;
                    </div>
                    <div class="col-md-2">
                        <form role="form" id="time_date" method="POST" action="/business/time">
                        <div class="form-group">
                            <a href="#" id="previous_date" class="fa fa-arrow-left" style="display: inline;" onClick="moveDate('prev');"></a>&nbsp;<input id="select_date" class="form-control" placeholder="Select Date" type="text" name="entry_date" style="width: 100px; display: inline;" value="{{ entry_date }}" onchange="this.form.submit()">&nbsp;<a href="#" id="next_date" class="fa fa-arrow-right" style="display: inline;" onClick="moveDate('next');"></a>
                        </div>
                        </form>
                    </div>
                </div>
                <div class="row">&nbsp;</div>
                {% if not time_entries %}
                <p align="center"><b>No time entries for this day</b></p>
                {% else %}
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th style="width:400px;">&nbsp;</th>
                                <th>Client</th>
                                <th>Total Time</th>
                                <th>Work Performed</th>
                            </tr>
                        </thead>
                        <tbody>
                        {% for entry in time_entries %}
                            {% if entry.start_time == '0000-00-00 00:00:00' %}
                                {% set icon_class = 'btn-success' %}
                                {% set icon = 'fa-play' %}
                                {% set row_class = '' %}
                            {% else %}
                                {% set icon_class = 'btn-danger' %}
                                {% set icon = 'fa-stop' %}
                                {% set row_class = 'success' %}
                            {% endif %}
                            <tr class="{{ row_class }}">
                                <td style="width:300px; white-space: nowrap;">
                                    <a class="btn btn-primary btn-circle fa fa-edit" href="/business/time/{{ entry.id }}"></a>&nbsp;
                                    <a class="btn btn-danger btn-circle fa fa-times delete_time" entry_id="{{ entry.id }}"></a>&nbsp;
                                    <a class="btn {{ icon_class }} btn-circle fa {{ icon }}" href="/business/setTime/{{ entry.id }}"></a>
                                </td>
                                <td class="client_name">{{ entry.client }}</td>
                                <td class="total_time">{{ entry.total_time }}</td>
                                <td><pre style="white-space: pre-wrap;">{{ entry.work_performed }}</pre></td>
                            </tr>                      
                        {% endfor %}
                        </tbody>
                        <tfoot>
                            <tr>
                                <th>&nbsp;</th>
                                <th width="25%" style="text-align: right; padding-right: 30px;">Today's Total</th>
                                <th width="10%">{{ day_total }}</th>
                                <th width="55%">&nbsp;</th>
                            </tr>
                        </tfoot>
                    </table>
                </div>
                {% endif %}
                </div>
            </div>
       </div>
   </div>
</div>
<form id="delete_time_form" method="POST" action="/business/deleteTime">
    <input type="hidden" name="entry_id" id="delete_entry_id" value="0">
</form>
{% include 'kiss_modal.tpl' %}
<script>
function moveDate(dir) {
    var current = $("#select_date").datepicker('getDate');
    if(dir == 'prev') {
        current.setTime(current.getTime() - (1000*60*60*24));
    } else {
        current.setTime(current.getTime() + (1000*60*60*24));
    }
    $("#select_date").datepicker('setDate', current);
    $("#time_date").submit();
}
$(document).ready(function() {
    $("#select_date").datepicker({
        dateFormat: "yy-mm-dd",
    });
    $("#entry_date").datepicker({
        dateFormat: "yy-mm-dd",
    });
    $(".delete_time").click(function(){
        var entry_id = $(this).attr('entry_id');
        $("#delete_entry_id").val(entry_id);
        var client_name = $(this).closest('tr').find('.client_name').html();
        var total_time = $(this).closest('tr').find('.total_time').html();
        var check = "Are you sure you want to delete this time entry: " + total_time + " for " + client_name;
        $("#modal_body").html(check);
        $('#kiss_modal').modal('show');
    });
    $("#kiss_modal_confirm").click(function(event){
        $('#kiss_modal').modal('hide');
        $("#delete_time_form").submit();
    });
});
</script>
{% endblock %}