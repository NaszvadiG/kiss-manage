{% extends "wrapper.tpl" %}
{% block content %}
<br>
<div class="row">
    <div class="col-md-6">
        <div class="panel panel-primary">
            <div class="panel-heading">
               <b>Updating {{ show.name }} season {{ season.season }}</b>
            </div>
            <div class="panel-body" >
                <form role="form" id="tv_season_edit" method="POST" action="/media/doEditSeason">
                <input type="hidden" name="season_id" value="{{ season.id|default('0') }}">
                <input type="hidden" name="season[tv_shows_id]" value="{{ season.tv_shows_id }}">
                <div class="form-group">
                    <label>Season</label>
                    <input class="form-control" id="season" placeholder="Enter Season Number" type="text" name="season[season]" value="{{ season.season }}" style="width: 120px;" data-validation="required" data-validation-error-msg="You must provide a season number">
                </div>
                <div class="form-group">
                    <label>End Date</label>
                    <input id="end_date" class="form-control" placeholder="Select Date" type="text" name="season[end_date]" style="width: 120px;" value="{{ season.end_date }}">
                </div>
                <div class="table-responsive">
                    <table class="table table-striped" id="manage-table">
                        <thead>
                            <tr>
                                <th width="10%">Episode</th>
                                <th>Air Date</th>
                                <th style="text-align: center;">Downloaded <a class="fa fa-check" href="#" id="toggle_dl"></a></th>
                                <th style="text-align: center;">Delete <a class="fa fa-check" href="#" id="toggle_delete"></a></th>
                            </tr>
                        </thead>
                        <tbody id="container">
                        {% for episode in episodes %}
                        <tr>
                            <td style="vertical-align: middle;">
                                <input class="form-control" type="text" name="eps[{{ episode.id }}][episode]" value="{{ episode.episode }}">
                            </td>
                            <td style="vertical-align: middle; text-align: center;">
                                <input class="form-control air_date" type="text" name="eps[{{ episode.id }}][air_date]" style="width: 100px;" value="{{ episode.air_date }}">
                            </td>
                            <td style="vertical-align: middle; text-align: center;">
                                <input type="checkbox" class="set_dl" name="eps[{{ episode.id }}][downloaded]" value="1" {{ episode.downloaded ? 'checked' : '' }}>
                            </td>
                            <td style="vertical-align: middle; text-align: center;">
                                <input type="checkbox" class="set_delete" name="eps[{{ episode.id }}][delete]" value="1">
                            </td>
                        </tr>
                        {% endfor %}
                        </tbody>
                        <tfoot>
                            <tr>
                                <td colspan="2"style="text-align: left;"><button type="button" class="btn btn-default fa fa-plus" id="add_episode_row"></button></td>
                                <td colspan="2" style="text-align: right;"><button type="submit" class="btn btn-primary">Save</button></td>
                            </tr>
                        </tfoot>
                    </table>
                </div>
                </form>
            </div>
        </div>
    </div>
</div>
<script>
var new_eps_counter = 0;
$(function() {
    $("#end_date").datepicker({
        dateFormat: "yy-mm-dd",
    });
    $(".air_date").datepicker({
        dateFormat: "yy-mm-dd",
    });
    $("#toggle_dl").click(function(){
        $(".set_dl").each(function() {
            $(this).click();
        });
        return false;
    });
    $("#toggle_delete").click(function(){
        $(".set_delete").each(function() {
            $(this).click();
        });
        return false;
    });
    $("#add_episode_row").click(function(){
        $('#manage-table > tbody:last').append('<tr><td style="vertical-align: middle; text-align: center;"><input class="form-control" type="text" name="neweps['+new_eps_counter+'][episode]" value=""></td><td style="vertical-align: middle; text-align: center;"><input class="form-control air_date_new" type="text" name="neweps['+new_eps_counter+'][air_date]" style="width: 100px;" value=""></td><td style="vertical-align: middle; text-align: center;"><input type="checkbox" class="set_dl" name="neweps['+new_eps_counter+'][downloaded]" value="1"></td><td style="vertical-align: middle; text-align: center;">&nbsp;</td></tr>');
        new_eps_counter++;

        // Initialize our new row's date picker
        $('#manage-table > tbody:last').find(".air_date_new").datepicker({
            dateFormat: "yy-mm-dd",
        });

        // Set focus to the new row
        $("tbody#container tr:last td:first input").focus();
    });
});
</script>
{% endblock %}