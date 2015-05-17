{% extends "wrapper.tpl" %}
{% block content %}
<br>
<div class="row">
    <div class="col-md-8">
        <div class="panel panel-primary">
            <div class="panel-heading">
               <b>Pending TV Downloads</b>
            </div>
            <div class="panel-body" >
                <div class="row">
                    <div class="col-md-4">
                        <form role="form" id="tv_edit" method="POST" action="/media/pendingTv">
                        <div class="form-group">
                            <label>End Date:&nbsp;</label><input id="end_date" class="form-control" placeholder="Select Date" type="text" name="end_date" style="width: 100px;" value="{{ end_date }}" onchange="this.form.submit()">
                        </div>
                        </form>
                    </div>
                    <div class="col-md-8">
                        <div class="alert alert-success" id="copied_text" style="display: none;"></div>
                    </div>
                </div>
                {% if not pending_tv %}
                <p align="center">No pending shows found</p>
                {% else %}
                <div class="table-responsive">
                    <table class="table table-striped">
                        <thead>
                            <tr>
                                <th width="15%">&nbsp;</th>
                                <th width="50%">Show</th>
                                <th width="12%">Episode</th>
                                <th width="15%">Air Date</th>
                            </tr>
                        </thead>
                        <tbody>
                        {% for show in pending_tv %}
                            {% set to_get = "s%02se%02s"|format(show.season, show.episode) %}
                            {% set copydl = show.name ~ ' ' ~ to_get %}           
                            <tr>
                                <td style="vertical-align: middle;">
                                    <a class="btn btn-success btn-circle fa fa-copy copydl" data-clipboard-text="{{ copydl }}"></a>
                                    <a class="btn btn-danger btn-circle fa fa-check" href="/media/setEpisodeDownloaded/{{ show.episode_id }}"></a>
                                </td>
                                <td style="vertical-align: middle;"><a href="/media/editTv/{{ show.id }}/{{ show.season_id }}">{{ show.name }}</a></td>
                                <td style="vertical-align: middle;">{{ to_get }}</td>
                                <td style="vertical-align: middle;">{{ show.air_date }}</td>
                            </tr>
                        {% endfor %}
                        </tbody>
                    </table>
                </div>
                {% endif %}
            </div>
        </div>
    </div>
</div>
<script src="/js/ZeroClipboard.js"></script>
<script>
$(function() {
    $("#end_date").datepicker({
        dateFormat: "yy-mm-dd",
        beforeShow: function (textbox, instance) {
            instance.dpDiv.css({
                    marginTop: (-textbox.offsetHeight) + 'px',
                    marginLeft: textbox.offsetWidth + 'px'
            });
        }
    });
});
var clientText = new ZeroClipboard($(".copydl"), {
              moviePath: "/js/ZeroClipboard.swf",
              debug: false
} );

clientText.on( "ready", function( readyEvent ) {
    clientText.on("aftercopy", function(event) {
        $("#copied_text").html("Copied "+event.data['text/plain']+" to clipboard");
        $("#copied_text").fadeIn('fast');
        $("#copied_text").fadeOut(4000);
    });
});
</script>
{% endblock %}