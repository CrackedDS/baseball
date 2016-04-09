$(document).on("page:load ready", function() {

  $(".team-select-1").change(function() {
    $.ajax({
      url: "player_list_team",
      dataType: "json",
      data: {
        term: this.value
      },
      success: function( data ) {
        console.log(data);
        $(".player-select-1").empty();
        $.each(data.players, function() {
          $(".player-select-1").append($("<option />").val(this.value).text(this.label));
        });
      }
    });
  });

  $(".team-select-2").change(function() {
    $.ajax({
      url: "player_list_team",
      dataType: "json",
      data: {
        term: this.value
      },
      success: function( data ) {
        console.log(data);
        $(".player-select-2").empty();
        $.each(data.managers, function() {
          $(".player-select-2").append($("<option />").val(this.value).text(this.label));
        });
      }
    });
  });

  $(".team-m-select-1").change(function() {
    $.ajax({
      url: "manager_list_team",
      dataType: "json",
      data: {
        term: this.value
      },
      success: function( data ) {
        console.log(data);
        $(".manager-select-1").empty();
        $.each(data.managers, function() {
          $(".manager-select-1").append($("<option />").val(this.value).text(this.label));
        });
      }
    });
  });

  $(".team-m-select-2").change(function() {
    $.ajax({
      url: "manager_list_team",
      dataType: "json",
      data: {
        term: this.value
      },
      success: function( data ) {
        console.log(data);
        $(".manager-select-2").empty();
        $.each(data.managers, function() {
          $(".manager-select-2").append($("<option />").val(this.value).text(this.label));
        });
      }
    });
  });
});