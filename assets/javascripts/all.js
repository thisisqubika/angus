$(document).ready(function(){

  $('.navigation').localScroll();

  $('section').waypoint(function(direction) {
    var me = $(this); //added
    thisId = $(this).attr('id');
    $('ul.nav li a').each(function(){
      var secondaryID = $(this).attr('class');
      if  ( secondaryID == thisId )
          {
            $('ul li a').removeClass('active');
                  
                  //added
                  if(direction==='up'){
                      me = $(this).prev();
                  }
                  
                  //added
                  if(!me.length){
                      me = $(this);
                  }
                  
              $(this).addClass('active');
          }
      });
  },{ offset: 20 }); 
 
  $('a[href*=#]:not([href=#])').click(function() {
      if (location.pathname.replace(/^\//,'') == this.pathname.replace(/^\//,'') 
          || location.hostname == this.hostname) {
          var target = $(this.hash);
          target = target.length ? target : $('[name=' + this.hash.slice(1) +']');
             if (target.length) {
               $('html,body').animate({
                  scrollTop: target.offset().top
              }, 0);
              return false;
          }
      }
  });

  $('section#getting_started').waypoint(function(direction){
    $("li.home").toggleClass("visible");
    $(".navigation ul.nav").toggleClass("fixed");
  },{offset: 20})

  $('.navigation li.home').waypoint(function(direction){
    $(".navigation").toggleClass("mobile-fixed");
  },{offset: 0})

});

