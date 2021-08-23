import { ImageCropper } from './cropper.js'

$(document).ready(function() {
  var cropper;

  $("body").on("shown.bs.modal", "#cropper-modal", function() {
    cropper = ImageCropper.init();
  });

  $("body").on("hidden.bs.modal", "#cropper-modal", function() {
    $(".apply-crop-btn").trigger("click");
    cropper.destroy();
  });

  $("body").on("click", ".apply-crop-btn", function() {
    var inputFileEl = $(this).attr("data-form-img-id");
    var dropzoneEl = $(this).attr("data-dropzone-id");
    var canvas = cropper.getCroppedCanvas();
    if(canvas){
      var dataURI = canvas.toDataURL();

      fetch(dataURI)
      .then(res => res.blob())
      .then(blob => {
        var mime = dataURI.split(',')[0].match(/:(.*?);/)[1];
        var file = new File([blob], `image.${mime.split("/")[1]}`,{ type: mime });
        
        FILEFORMDATA.set($(`${inputFileEl}`).attr('name'), file);

        if( $(`${dropzoneEl} [data-dz-thumbnail]`).length ){ //uses dropdzone
          $(`${dropzoneEl} [data-dz-thumbnail]`).attr("src", dataURI);
        }else {
          $(`${dropzoneEl}`).parent().removeClass("d-none");
          $(`${dropzoneEl}`).attr("src", dataURI);
        }
        // edit omnibous sponsor image display
        if($(`.omnibous-edit ${dropzoneEl}`).length){
          $(`.omnibous-edit ${dropzoneEl}`).css("background-image", "url(" + dataURI + ")");
        }

        $("#cropper-modal").modal("hide");

      });
    }
  });
})