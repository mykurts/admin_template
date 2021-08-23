

jQuery(document).ready(function() {

  $(document).on('click', '.show-password', function(){
    $(this).find(".fa-eye").toggleClass("active");

    if( $(this).find(".fa-eye").hasClass("active") ) {
      $(this).prev().attr("type", "text");
    }else{
      $(this).prev().attr("type", "password");
    }
  });
  
});