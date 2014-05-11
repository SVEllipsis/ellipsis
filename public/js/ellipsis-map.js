window.ellipsisMap = (function(){
  "use strict";

  var ellipsisMap = function(mapElem) {
    this.getData().done($.proxy(function(json){
      this.data = json;

      // TODO Guess initial center and zoom mased on data set
      this.map = new google.maps.Map(mapElem, {
        center: new google.maps.LatLng(45, 10),
        zoom: 5
      });

      this.addMarkers();
      this.addLine();
    }, this));
  };

  ellipsisMap.prototype = {
    getData: function() {
      return $.ajax('/map.json');
    },

    addMarkers: function() {
      var map = this.map;
      var markers = [];

      for (var i in this.data) {
        var point = this.data[i];
        var created_at = new Date((point.created_at));

        // TODO Give latest marker a custom icon
        // Add marker
        var marker = (new google.maps.Marker({
          position: new google.maps.LatLng(point.lat, point.long),
          animation: google.maps.Animation.DROP,
          title: this.formatDate(created_at)
        }));

        this.buildAndAttachInfoWindow(marker, point);
        markers.push(marker);
      }

      // Drop points onto the map one after the other
      // TODO Make this drop strings one after the other
      for (i in markers) {
        // setTimeout(function() {
          this.dropMarkerOntoMap(markers[i], map);
        // }, i * 200);
      }
    },

    addLine: function() {
      var linePath = [];

      for (var i in this.data) {
        linePath.push(new google.maps.LatLng(this.data[i].lat, this.data[i].long));
      }

      var line = new google.maps.Polyline({
          path: linePath,
          geodesic: true,
          strokeColor: '#FF0000',
          strokeOpacity: 1.0,
          strokeWeight: 2,
          icons: [{
            icon: {
              path: google.maps.SymbolPath.FORWARD_CLOSED_ARROW
            },
            repeat: '100px',
            offset: '30px'
          }],
        });

      // TODO Draw line after pointers are dropped onto the map, not before
      line.setMap(this.map);
    },

    buildAndAttachInfoWindow: function(marker, point) {
      var created_at = new Date((point.created_at));

      // Add info window that shall appear when marker is clicked
      var content = '<div class="map__info"><h2>' + this.formatDate(created_at) + '</h2>' +
        '<ul>' +
        '<li>Bearing: ' + point.bearing + '</li>'+
        '<li>Coordinates: <span class="map__info__coordinates">' + point.lat + ', ' + point.long + '</span></li>' +
        '</ul></div>';

      var infoWindow = new google.maps.InfoWindow({
        content: content
      });

      google.maps.event.addListener(marker, 'click', function() {
        infoWindow.open(marker.getMap(), marker);
      });
    },

    dropMarkerOntoMap: function(marker, map) {
      marker.setMap(map);
    },

   formatDate: function(date) {
      return date.getUTCFullYear() +
        '-' + this._zeroPad(date.getUTCMonth() + 1 ) +
        '-' + this._zeroPad(date.getUTCDate()) +
        ' ' + this._zeroPad(date.getUTCHours()) +
        ':' + this._zeroPad(date.getUTCMinutes());
    },

    _zeroPad: function(number) {
      return (number < 10 ? '0' + number : number);
    }
  };



  return ellipsisMap;
}());
