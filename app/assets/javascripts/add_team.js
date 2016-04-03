$(document).on("page:load ready", function() {

  $("#add_team_player").autocomplete({
    source: function(request, response) {
      $.ajax({
        url: "player_list",
        dataType: "json",
        data: {
          term: request.term
        },
        success: function( data ) {
          response(data.players);
        }
      });
    },
    minLength: 3,
    select: function(event, ui) {
        $('#add_team_player').val(ui.item.label);
        return false; // Prevent the widget from inserting the value.
    },
    change: function (event, ui) {
      if(!ui.item){
          //http://api.jqueryui.com/autocomplete/#event-change -
          // The item selected from the menu, if any. Otherwise the property is null
          //so clear the item for force selection
          $("#add_team_player").val("");
      }
    }
  })

});