$(document).on("page:load ready", function() {

  $("#player_name").autocomplete({
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
        $('#player_name').val("");
        $('#_selected_players').append("<option selected value=" + ui.item.value + ">" + ui.item.label + "</option>")
        return false; // Prevent the widget from inserting the value.
    },
    change: function (event, ui) {
      if(!ui.item){
          //http://api.jqueryui.com/autocomplete/#event-change -
          // The item selected from the menu, if any. Otherwise the property is null
          //so clear the item for force selection
          $("#player_name").val("");
      }
    }
  })


  $('.datatable').DataTable({
    // ajax: ...,
    // autoWidth: false,
    lengthChange: false,
    searching: false
    // pagingType: 'full_numbers',
    // processing: true,
    // serverSide: true,

    // Optional, if you want full pagination controls.
    // Check dataTables documentation to learn more about available options.
    // http://datatables.net/reference/option/pagingType
  });

  $('.datatable-nopaging').DataTable({
    // ajax: ...,
    // autoWidth: false,
    lengthChange: false,
    searching: false,
    paging: false,
    info:false
    // pagingType: 'full_numbers',
    // processing: true,
    // serverSide: true,

    // Optional, if you want full pagination controls.
    // Check dataTables documentation to learn more about available options.
    // http://datatables.net/reference/option/pagingType
  });
});