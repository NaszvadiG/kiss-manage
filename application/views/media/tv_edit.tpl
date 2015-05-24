{% extends "wrapper.tpl" %}
{% block content %}
<div class="row">
    <div class="col-lg-5">
        <div class="panel panel-default">
            <div class="panel-heading">
               <b>{{ id ? 'Update Show' : 'Add New Show' }}</b>
            </div>
            <div class="panel-body" style="margin: 20px;">
                <div class="row">
                    <form role="form" id="tv_edit" method="POST" action="/media/doEditTv">
                        <input type="hidden" name="id" value="{{ id|default('0') }}">
                        <div class="form-group">
                            <label>Show Name</label>
                            <input class="form-control" id="tv_show_name" placeholder="Enter Name" type="text" name="show[name]" value="{{ name }}" data-validation="required" data-validation-error-msg="You must provide a show name">
                        </div>
                        <div class="form-group">
                            <label>Server Folder</label>
                            <input class="form-control" placeholder="Enter Folder" type="text" name="show[folder]" value="{{ folder }}">
                        </div>
                        <div class="form-group">
                            <label>Disk Location</label>
                            <input class="form-control" placeholder="Enter Location" type="text" name="show[location]" value="{{ location }}">
                        </div>
                        <div class="form-group">
                            <label>TVDB Series ID &nbsp
                            {% if id > 0 and tvdb_seriesid == 0 %}
                            <a href="http://thetvdb.com/?string={{ name|url_encode }}&searchseriesid=&tab=listseries&function=Search" target="_blank">Click here to search</a>
                            {% else %}
                            <a href="http://thetvdb.com/?tab=series&id={{ tvdb_seriesid }}" target="_blank" class="btn fa fa-external-link"></a>
                            {% endif %}
                            </label>
                            <input class="form-control" placeholder="Enter TVDB Series ID" type="text" name="show[tvdb_seriesid]" value="{{ tvdb_seriesid }}">
                        </div>
                        <div class="form-group">
                            <label>Last Updated Date</label>
                            <input id="last_updated" class="form-control" placeholder="Select Date" type="text" name="show[last_updated]" style="width: 120px;" value="{{ last_updated }}">
                        </div>
                        <div class="form-group">
                            <div class="checkbox">
                                <label>
                                    <input type="checkbox" name="show[status]" value="1" {{ status == 1 ? 'checked' : '' }}>&nbsp;Monitor?
                                </label>
                            </div>
                        </div>
                        <div class="form-group">
                            <label>Special Notes</label>
                            <textarea class="form-control" placeholder="Enter special notes" name="show[special_notes]" style="height: 100px;">{{ special_notes }}</textarea>
                        </div>
                        <button type="submit" class="btn btn-primary" id="tv_edit_save">Save</button>&nbsp;
                        {% if id > 0 %}
                        <a class="btn btn-danger" id="delete_show_button" href="#">Delete</a>
                        {% endif %}                           
                    </form>
                    <form id="delete_show_form" method="POST" action="/media/deleteTvShow">
                        <input id="delete_show_id" type="hidden" name="delete_show_id" value="{{ id }}">
                        <input id="delete_show_message" type="hidden" name="message" value="">
                    </form>
                </div>
            </div>
        </div>
    </div>
    {% if id > 0 %}
    <div class="col-lg-7">
        <div class="panel panel-default">
            <div class="panel-heading">
               <b>Seasons</b>
            </div>
            <div class="panel-body" style="margin: 20px;">
                {% if not seasons %}
                <p align="center">No seasons found</p>
                {% else %}
                <div class="table-responsive">
                    <table class="table table-striped table-bordered table-hover">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Total Eps</th>
                                <th>D/L Eps</th>
                                <th>End Date</th>
                                <th>&nbsp;</th>
                            </tr>
                        </thead>
                        <tbody>
                        {% for season in seasons %}
                        <tr>
                            <td style="vertical-align: middle;" class="season_name">{{ season.season }}</td>
                            <td style="vertical-align: middle;">{{ episodes[season.id].episodes }}</td>
                            <td style="vertical-align: middle;">{{ episodes[season.id].downloaded_episodes }}</td>
                            <td style="vertical-align: middle;">{{ episodes[season.id].end_date }}</td>
                            <td style="vertical-align: middle; text-align: center; width: 90px;">
                                <a class="btn btn-success btn-circle fa fa-edit" href="/media/editSeason/{{ season.id }}"></a>
                                <a class="btn btn-danger btn-circle fa fa-times delete_row" season_id="{{ season.id }}" href="#"></a>
                            </td>
                            <a ></a>
                        </tr>
                        {% endfor %}
                        </tbody>
                    </table>
                </div>
                <form id="delete_season_form" method="POST" action="/media/deleteTvSeason">
                    <input id="tv_shows_id" type="hidden" name="tv_shows_id" value="{{ id }}">
                    <input id="delete_season_id" type="hidden" name="season_id" value="">
                    <input id="delete_season_message" type="hidden" name="message" value="">
                </form>
                {% endif %}
                <p align="left">
                <a class="btn btn-primary" href="/media/editSeason/0/{{ id }}">Add Season</a>&nbsp;
                {% if tvdb_seriesid > 0 %}
                    <a class="btn btn-default" href="/media/refreshTVDB/{{ id }}">Refresh from TVDB</a>&nbsp;
                    <a class="btn btn-default" href="/media/setShowDownloaded/{{ id }}">Set all downloaded</a>
                {% endif %}
                </p>
            </div>
        </div>
    </div>
    {% endif %}
</div>
{% include 'kiss_modal.tpl' %}
<script>
$(document).ready(function() {
    $.validate({
        onError : function() {
            return false;
        }
    });
    $("#last_updated").datepicker({
        dateFormat: "yy-mm-dd",
        beforeShow: function (textbox, instance) {
            instance.dpDiv.css({
                    marginTop: (-textbox.offsetHeight) + 'px',
                    marginLeft: textbox.offsetWidth + 'px'
            });
        }
    });
    $(".delete_row").click(function(){
        var season_id = $(this).attr('season_id');
        $("#delete_season_id").val(season_id);
        var tv_show_name = $("#tv_show_name").val();
        var season_name = $(this).closest('tr').find('.season_name').html();
        var delete_message = tv_show_name+" season "+season_name;
        $("#delete_season_message").val(delete_message);
        var confirm = "<p>Are you sure you want to delete: "+delete_message+"?  All related episodes will also be deleted.</p><input type=\"hidden\" name=\"confirm_type\" id=\"confirm_type\" value=\"season\">";
        $("#modal_body").html(confirm);
        $('#kiss_modal').modal('show');
    });
    $("#delete_show_button").click(function() {
        var tv_show_name = $("#tv_show_name").val();
        $("#delete_show_message").val(tv_show_name);
        var confirm = "<p>Are you sure you want to delete: "+tv_show_name+"?  All related seasons & episodes will also be deleted.</p><input type=\"hidden\" name=\"confirm_type\" id=\"confirm_type\" value=\"show\">";
        $("#modal_body").html(confirm);
        $('#kiss_modal').modal('show');
    });
    $("#kiss_modal_confirm").click(function(event){
        var type = $("#confirm_type").val();
        $('#kiss_modal').modal('hide');
        if(type == 'show') {
            $("#delete_show_form").submit();
        } else {
            $("#delete_season_form").submit();
        }
    });
});
</script>
{% endblock %}