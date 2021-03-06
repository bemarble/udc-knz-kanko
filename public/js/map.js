
var map;
var features = [];
var mylatlng;

$('document').ready(function(){
  google.maps.event.addDomListener(window, 'load', initialize);


  $('#add_req').on('click', function(){
    $('#modal-window').modal();
    $('#modal-window').modal({ keyboard: false });
    $('#modal-window').modal('show');

    return false;
  });

  $('#register_state').on('click', function() {
    if ($(".selectpicker").val() == "0") {
      alert("場所を入力してください");
      return false;
    }

    if (!mylatlng) {
      alert("GPSを有効にしてください");
      return false;
    }
    $.ajax({
      type: 'post',
      url: '/register_state',
      data: {
        'help': $('#help').bootstrapSwitch('state'),
        'open_id': $(".selectpicker").val(),
        'lat': mylatlng.lat(),
        'lng' : mylatlng.lng()
      },
      success: function() {
        $('#modal-window').modal('hide');
        console.log("reg");
      }
    });
  });

  $('#send_message').on('click', function() {

    console.log($('#to-id').val());
    $.ajax({
      type: 'post',
      url: '/send_message',
      data: {
        'message': $('mail-body').val(),
        'to': 1,

      },
      success: function() {

      }
    });
  });


  $("#help").bootstrapSwitch();

});

function initialize()
{
  var tokyo = new google.maps.LatLng(35.689614,139.691585);
  var opts = {
    zoom: 16,
    center: tokyo,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  };

  map = new google.maps.Map(document.getElementById("map-container"), opts);

  setMyPoint();
  mapRefresh();
  mapRefresh4odata();
}

function setMyPoint()
{
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(function(position) {
      mylatlng = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);

      map.setCenter(mylatlng);

      var marker = new google.maps.Marker({
        position: mylatlng,
        map: map,
        title: '現在地'
      });
    }, function (e) {
    });
  }
}

function mapRefresh() {
  var ctime = (new Date()).getTime();
  var myKMLLayer = new google.maps.KmlLayer("http://udc-knz-kanko.herokuapp.com/kml/post.kml?" + ctime);
  myKMLLayer.setMap(map);

/*
  $.getJSON('/geo/', function (data) {
    for (var i = 0; i < features.length; i++) {
      map.data.remove(features[i]);
    }

    features = map.data.addGeoJson(data);
  });

  map.data.setStyle(function(feature) {
    var theaterName = feature.getProperty('want_to_go');
    return {
      icon: {url: feature.getProperty('icon')},
      visible: true,
      clickable: true,
      title: theaterName
    };
  });

  map.data.addListener('click', function(event){
    // show user info

    $.ajax({
      type: 'post',
      url: '/user/',
      dataType: 'json',
      data: {
        id:event.feature.getProperty("id")
      },
      success: function(data) {
        console.log(data.name);
      }
    });
    $('#user-info').modal();
    $('#user-info').modal({ keyboard: false });
    $('#user-info').modal('show');

    $('#to-id').val();
  });

  map.data.addListener('addfeature', function(event) {
    var infowindow = new google.maps.InfoWindow();
    var description = event.feature.getProperty("want_to_go");
    var date = event.feature.getProperty("updated_at");

    infowindow.setContent("<div style='width:150px; text-align: center;'><div>"+description + "</div><div>" +date +"</div></div>");
    infowindow.setPosition(event.feature.getGeometry().get());
    infowindow.setOptions({pixelOffset: new google.maps.Size(0,-30)});
    infowindow.open(map);
  });
  */
}

function mapRefresh4odata() {
  var ctime = (new Date()).getTime();

  var myKMLLayer = new google.maps.KmlLayer("http://udc-knz-kanko.herokuapp.com/kml/opendata.kml?" + ctime);
  myKMLLayer.setMap(map);

/*
  $.getJSON('/opendata/', function (data) {
    for (var i = 0; i < features.length; i++) {
      map.data.remove(features[i]);
    }

    features = map.data.addGeoJson(data);
  });

  map.data.setStyle(function(feature) {
    var theaterName = feature.getProperty('name');
    return {
      icon: {url: "/img/favicon.ico" },
      visible: true,
      clickable: true,
      title: theaterName
    };
  });

  map.data.addListener('click', function(event) {
    var infowindow = new google.maps.InfoWindow();
    var description = event.feature.getProperty("description");
    var open_id = event.feature.getProperty("id");
    var date = event.feature.getProperty("updated_at");

    infowindow.setContent("<div style='width:100px; text-align: center;'><div>"+description+"</div><img src='/img/thumb/"+open_id+".jpg' /></div>");
    infowindow.setPosition(event.feature.getGeometry().get());
    infowindow.setOptions({pixelOffset: new google.maps.Size(0,-30)});
    infowindow.open(map);
  });
*/
}
