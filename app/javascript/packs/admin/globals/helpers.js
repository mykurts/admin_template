export const http_request=(url, method, body = null,  headers={
  'Content-Type': 'application/json',
  'X-CSRF-Token': $("meta[name='csrf-token']").attr("content")
  })=>{
  let status = null;
  let options = {
    method: method,
    headers: headers,
    body: JSON.stringify(body)
  }

  if(method == 'GET'){
    options = {
      method: method,
      headers: headers
    }
  }
  return fetch(url, options).then(response =>{
      status = response.status;
      return response.json();
    })
    .then(data => {
    return {
      status: status,
      data: data
    }

    })
    .catch(error => {
      console.log(error);
    });
}


export const convertToBase64=(event, img_id, dropzone_id) => {
  var $modal = $("#cropper-modal");
  var reader = new FileReader();
  reader.readAsDataURL(event[0]);
  reader.onload = function () {

    $modal.find("img#image").attr("src", reader.result);
    $modal.find(".apply-crop-btn").attr("data-form-img-id", img_id);
    $modal.find(".apply-crop-btn").attr("data-dropzone-id", dropzone_id);
    $modal.modal();
  };
  reader.onerror = function (error) {
    console.log('Error: ', error);
  };
}