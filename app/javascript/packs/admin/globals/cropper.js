'use strict';

// Class definition
var ImageCropper = function() {

  // Private functions
  var initCropperDemo = function() {
    var image = document.getElementById('image');
    var options = {
      crop: function(event) {
        var lg = document.getElementById('cropper-preview-lg');
        lg.innerHTML = '';
        lg.appendChild(cropper.getCroppedCanvas({width: 256, height: 160}));
      },
    };

    var cropper = new Cropper(image, options);

    var buttons = document.getElementById('cropper-buttons');
    var methods = buttons.querySelectorAll('[data-method]');
    methods.forEach(function(button) {
      button.addEventListener('click', function(e) {
        var method = button.getAttribute('data-method');
        var option = button.getAttribute('data-option');
        var option2 = button.getAttribute('data-second-option');

        try {
          option = JSON.parse(option);
        }
        catch (e) {
        }

        var result;
        if (!option2) {
          result = cropper[method](option, option2);
        }
        else if (option) {
          result = cropper[method](option);
        }
        else {
          result = cropper[method]();
        }

        if (method === 'getCroppedCanvas') {
          var modal = document.getElementById('getCroppedCanvasModal');
          var modalBody = modal.querySelector('.modal-body');
          modalBody.innerHTML = '';
          modalBody.appendChild(result);
        }

        var input = document.querySelector('#putData');
        try {
          input.value = JSON.stringify(result);
        }
        catch (e) {
          if (!result) {
            input.value = result;
          }
        }
      });
    });

    // set aspect ratio option buttons
    var radioOptions = document.getElementById('setAspectRatio').querySelectorAll('[name="aspectRatio"]');
    radioOptions.forEach(function(button) {
      button.addEventListener('click', function(e) {
        cropper.setAspectRatio(e.target.value);
      });
    });

    return cropper;
  };

  return {
    // public functions
    init: function() {
      return initCropperDemo();
    },
  };
}();

export { ImageCropper }
