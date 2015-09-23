{% extends "wrapper.tpl" %}
{% block content %}
<div class="row">
    <div class="col-md-6">
        <div class="panel panel-primary">
            <div class="panel-heading">
                Technical Notes
            </div>
            <div class="panel-body">
                <div class="row">
                    <div class="col-md-6">
                        <input class="form-control" type="text" id="search_text" value="">
                    </div>
                    <div class="col-md-6">
                        <button type="button" id="do_search" class="btn btn-small btn-default">Search</button>&nbsp;
                        <button type="button" id="clear_search" class="btn btn-small btn-default">Clear</button>
                    </div>
                </div>
                <div class="row">&nbsp;</div>
                <div class="row">
                    <div class="col-md-12">
                        <div id="notes_tree"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-6">
        <div class="panel panel-primary">
            <div class="panel-heading">
                Note Details
            </div>
            <div class="panel-body">
                <form role="form" id="note_details_form" method="POST" action="/tech/setNote">
                    <input type="hidden" id="note_id" name="note_id" value="{{ note.id|default('0') }}">
                    <div class="form-group">
                        <label>Parent</label>
                        <select class="form-control" id="parent_id" name="note[parent_id]">
                            <option value="0">- Top -</option>
                            {% for option in hierarchy_options %}
                            {{ option|raw }}
                            {% endfor %}
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Name</label>
                        <input class="form-control" type="text" id="note_name" name="note[name]" value="{{ note.name }}">
                    </div>
                    <div class="form-group">
                        <label>Note&nbsp;&nbsp;<a class="btn btn-primary btn-circle fa fa-copy" id="copy_note" data-clipboard-text="{{ note.data }}"></a></label>
                        <textarea class="form-control" id="note_data" name="note[data]" style="height: 300px;" placeholder="Select a note to view its data">{{ note.data }}</textarea>
                    </div>
                    <div class="form-group">
                        <button type="submit" id="save" class="btn btn-small btn-primary">Save</button>&nbsp;
                        <button type="button" id="delete_note" class="btn btn-small btn-danger" style="display: {{ note.id > 0 ? '' : 'none' }};">Delete</button>
                        <button type="button" id="add_to_parent" class="btn btn-small btn-default">Add new to this parent</button>&nbsp;
                        <button type="button" id="add_to_node" class="btn btn-small btn-default">Add new to this node</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
<form id="delete_note_form" method="POST" action="/tech/deleteNote">
    <input id="delete_note_id" type="hidden" name="note_id" value="">
</form>
{% include 'kiss_modal.tpl' %}
<script src="/js/ZeroClipboard.js"></script>
<script>
function setCookie(name, value, ex) {
    var d = new Date();
    d.setTime(d.getTime() + (ex*24*60*60*1000));
    var expires = "expires="+d.toUTCString();
    document.cookie = name + "=" + value + "; " + expires +"; path=/";
}
function resetNote() {
    $("#note_id").val(0);
    $("#note_data").html('');
    $("#note_name").val('');
    $("#delete_note").css('display', 'none');
}
function search() {
    var pattern = $('#search_text').val();
    var results = $("#notes_tree").treeview('search', [pattern, {ignoreCase: true, exactMatch: false, revealResults: true}]);
}
$(document).ready(function() {
    $("#notes_tree").treeview({
        data: {{ tree_data|raw }}, 
        levels: 1, 
        expandIcon: 'glyphicon glyphicon-chevron-right', 
        collapseIcon: 'glyphicon glyphicon-chevron-down'
    });
    $('#notes_tree').on('nodeSelected', function(event, data) {
        $("#note_id").val(data.node_id);
        $("#note_data").html(data.data);
        $("#copy_note").attr('data-clipboard-text', data.data);
        $("#note_name").val(data.text);
        $("#parent_id").val(data.parent_id);
        $("#delete_note").css('display', '');
        setCookie("notes_tree_selected", data.node_id, 365);
    });
    $("#add_to_parent").click(function() {
        resetNote();
    });
    $("#add_to_node").click(function() {
        $("#parent_id").val($("#note_id").val());
        resetNote();
    });
    $("#do_search").click(function() {
        search();
    });
    $('#search_text').on('keyup', search);
    $("#clear_search").click(function() {
        $("#notes_tree").treeview('clearSearch');
        $('#search_text').val('');
    });
    $("#delete_note").click(function() {
        $("#delete_note_id").val($("#note_id").val());
        $("#modal_body").html("Are you sure you want to delete this entry: "+$("#note_name").val()+"?  All children will also be deleted.");
        $('#kiss_modal').modal('show');
    });
    $("#kiss_modal_confirm").click(function(event){
        $('#kiss_modal').modal('hide');
        $("#delete_note_form").submit();
    });
    $('#notes_tree').treeview('selectNode', [{{ selected_node }}, {silent: false}]);
    $('#notes_tree').treeview('revealNode', [{{ selected_node }}, {silent: true}]);

    var clientText = new ZeroClipboard($("#copy_note"), {
        moviePath: "/js/ZeroClipboard.swf",
        debug: false
    });
    clientText.on("ready", function(readyEvent) {
        clientText.on("aftercopy", function(event) {
            $("#copy_note").addClass("btn-success");
            $("#copy_note").removeClass("btn-success", 3000);
        });
    });
});
</script>
{% endblock %}