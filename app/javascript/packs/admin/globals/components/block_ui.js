"use strict";
// Class definition

var KTBlockUI = function () {

    // card blocking
    var _card_blocking = function (args) {

      KTApp.block(`${args.card_block}`, {
            overlayColor: '#000000',
            state: 'danger',
            message: '<span id="progress_msg">Please wait... </span>'
        });
      
    }
    var _card_unblocking = function (args) {
      KTApp.unblock(`${args.card_block}`);
    }

    return {
        // public functions
        init: function(args) {
          if(args.block){
            return  _card_blocking(args);
          }else{
            _card_unblocking(args);
          }
        }
    };
}();

export { KTBlockUI }

