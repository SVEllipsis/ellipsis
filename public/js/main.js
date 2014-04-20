$('html').removeClass('no-js');

/* AJAX Navigation - TODO make this a proper plugin */
(function($){
  //This shall only work on history API enabled browsers, if we haven't got it then use non-AJAX navigation
  //TODO add fallbacks using https://github.com/balupton/history.js
  if (!window.history.pushState) { return; }

  var $main = $('#main');
  var $sidebar = $('#sidebar ul');

  var navViewAttr = 'data-nav-view';
  var activeClass = 'active';

  function updateState(state, title, url, addToPushState) {
    $.get(url, function(data){
      //Add content
      $main.hide().empty().append(data).fadeIn();

      //Update title
      document.title = state.title + ' - Ellipsis';

      //Update active state in nav
      $sidebar.find('li.' + activeClass).removeClass(activeClass);
      $sidebar.find(':focus').blur();
      $sidebar.find('[' + navViewAttr + '=' + state.navViewActive + ']').addClass(activeClass);

      //Rebind form events
      window.bindFormEvents();

      //Push state to history
      if (addToPushState) {
        history.pushState(state, title, url);
      }

    });
  }

  function setInitialState() {
    //TODO separation of concerns - State shouldn't be stored in a css class
    var $initalLi = $sidebar.find('li.' + activeClass);
    var $initalA = $initalLi.find('a');

    history.replaceState(
      {
        title: $initalA.text(),
        navViewActive: $initalLi.attr(navViewAttr),
        url: $initalA.attr('href')
      },
      $initalLi.attr(navViewAttr),
      $initalLi.find('a').attr('href')
    );
  }

  $sidebar.find('a').click(function(e){
    e.preventDefault();
  });

  $sidebar.delegate('a', 'click', function(e){
    var $this = $(this);

    //TODO separation of concerns - State shouldn't be stored in a css class
    //Don't load anything if we're currently on that page
    if ($this.closest('li').hasClass('active')) {
      return false;
    }

    updateState(
      {
        title: $this.text(),
        navViewActive: $this.closest('li').attr(navViewAttr),
        url: $this.attr('href')
       },
      '',
      $this.attr('href'),
      true
    );

    return false;
  });

  window.onpopstate = function(event) {
    updateState(event.state, '', event.state.url);
  };

  setInitialState();
})(jQuery);

/* Form submission - every time we click events  */
(function($){
  function bindFormEvents() {
    //TODO we should use delegate instead of having to rebind events
    $('#main form.options').submit(function(){
      $.post("", function(data){
        //Fall back to standard form submission if no json onject
        if (!window.JSON) { return; }

        alert('AJAX call made to  server, returned object is:\n' + JSON.stringify(data));
      });

      return false;
    });

    var submitCurrentForm = function() {
      $(this.form).submit();
    };

    $('#main').find('input[type=radio], input[type=checkbox], select').change(submitCurrentForm)
  }

  bindFormEvents();

  //Expose globally so we can call from the navigation
  //TODO namespace this properly
  window.bindFormEvents = bindFormEvents;
})(jQuery);
