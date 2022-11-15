<!DOCTYPE html>
<html>
  <head>
    <title>Upload file to S3</title>
    <script src="https://unpkg.com/vue@1.0.28/dist/vue.js"></script>
    <script src="https://unpkg.com/axios@0.2.1/dist/axios.min.js"></script>
  </head>
  <body>
    <div id="app">
      <h1>S3 Uploader</h1>
  
      <div v-if="!file">
        <h2>Select a media file</h2>
        <input type="file" @change="onFileChange" accept="image/*, video/*">
      </div>
      <div v-else>
        <div v-if="!too_big">
          <img v-if="image" :src="image" />
          <video v-if="video" :src="video" width="320" height="240" controls></video>
          <br />
          <button v-if="!uploadURL" @click="removefile">Remove file</button>
          <button v-if="!uploadURL" @click="uploadfile">Upload file</button>
        </div>
      </div>
      <div v-if="too_big">
        <h2>File Too Big!</h2>
        <button @click="removefile">Remove file</button>
      </div>
      <div id="uploaded">
        <h2 v-if="uploadURL">Success! File uploaded as:</h2>
        <div id="filename"></div>
      </div>
      <div>
        <h2 v-if="uploadURL"> Select a media file</h2>
        <input type="file" v-if="uploadURL" @change="onFileChange" accept="image/*, video/*">
      </div>
      </br></br>
      <input type='text' id='dbsearch' name='dbsearch' placeholder='' required/> </p>
      <button @click="dynamodb">Search Dynamo</button>
      <div id="labels"></div>
      <div id="downloadimage"></div>
    </div>
  
    <script>
      const MAX_file_SIZE = 10000000
      const SIGNED_URL_API_ENDPOINT = 'https://signedurl.${domain}/signedurl?' 
      const PROCESS_API_ENDPOINT = 'https://process.${domain}/process?' 

      new Vue(
        {
          el: "#app",
          data: {
            file: '',
            uploadURL: '',
            file_extension: '',
            file_type: '',
            too_big: '',
            image: '',
            video: ''
          },

          methods: {
            onFileChange (e) {
              document.getElementById("filename").innerHTML = ""
              document.getElementById("labels").innerHTML = ""
              document.getElementById("downloadimage").innerHTML = ""

              this.uploadURL = ''
              let files = e.target.files || e.dataTransfer.files
              if (!files.length) return
              if (files[0].type.split("/")[0] == "image") {
                //If image, place in image div
                this.video = ''
                this.image = URL.createObjectURL(files[0])
              }
              if (files[0].type.split("/")[0] == "video") {
                //if video, place in video div with playback controls
                this.image = ''
                this.video = URL.createObjectURL(files[0])
              }
              this.createfile(files[0])
            },
            createfile (file) {
              let reader = new FileReader()
              reader.onload = (e) => {
                //check file length and show error if exceeded
                if (e.target.result.byteLength > MAX_file_SIZE) {
                  this.file = "Too big"
                  this.too_big = true
                  return
                }
                this.file = e.target.result
                this.file_extension = file.name.split('.').pop()
                this.file_type = file.type
              }
              reader.readAsArrayBuffer(file)
            },
            removefile: async function (e) {
              console.log('Remove clicked')
              document.getElementById("filename").innerHTML = ""
              this.file = ''
              this.file_extension = ''
              this.file_type = '' 
              this.big = ''
            },
            uploadfile: async function (e) {
              console.log('Upload clicked')
              console.log('Getting Signed URL: ', SIGNED_URL_API_ENDPOINT + 'file_extension=' + this.file_extension + '&content_type=' + this.file_type)
              const response = await axios({
                method: 'GET',
                url: SIGNED_URL_API_ENDPOINT + 'file_extension=' + this.file_extension + '&content_type=' + this.file_type
              })
              console.log('Get Signed URL Response: ', response)
              var arrayBufferView = new Uint8Array(this.file)
              let blobData = new Blob([ arrayBufferView ])
              console.log('Uploading to: ', response.uploadURL)
              const result = await fetch(response.uploadURL, {
                method: 'PUT',
                body: blobData,
                headers: {
                  'Content-Type': this.file_type
                }
              })
              console.log('Upload Result: ', result)
              const process_response = await axios({
                method: 'GET',
                url: PROCESS_API_ENDPOINT + 'file_name=' + response["Filename"]
              })
              console.log('Rekognition Response: ', process_response)
              this.uploadURL = response.uploadURL.split('?')[0]
              const filenameDiv = document.getElementById("filename")
              const heading = document.createElement("h1");
              heading.innerHTML = response["Filename"];
              filenameDiv.appendChild(heading)
            },
            dynamodb: async function (e) {
              this.removefile()
              this.uploadURL = ''
              const newSearch = document.getElementById('dbsearch');
              let newSearchValue= document.getElementById('dbsearch').value;
              console.log('Search DynamoDB: ', 'https://dynamo.${domain}/dynamo?file_name='+newSearchValue)
              const dyanmoresponse = await axios({
                method: 'GET',
                url: 'https://dynamo.${domain}/dynamo?file_name='+newSearchValue
              })
              console.log('Dynamo Search Response: ',dyanmoresponse)
              document.getElementById("labels").innerHTML = ""
              const labelsDiv = document.getElementById("labels")
              const labelslist = document.createElement("ul");
              labelsDiv.appendChild(labelslist);  

              for (let x in dyanmoresponse["Labels"]){
                let value = dyanmoresponse["Labels"][x];
                listItem = document.createElement("li");
                listItem.innerHTML = value;
                labelslist.appendChild(listItem);
              }
              for (let x in dyanmoresponse["File Names"]){
                let value = dyanmoresponse["File Names"][x];
                console.log('Retrieve Image: ', 'https://downloader.${domain}/downloader?file_name='+value)
                const downloaderresponse = await axios({
                  method: 'GET',
                  url: 'https://downloader.${domain}/downloader?file_name='+value
                })
                let url = (downloaderresponse["downloadURL"])
                listItem = document.createElement("li");
                listItem.innerHTML = "<img src="+url+" />";
                labelslist.appendChild(listItem);
              }
            }
          }
        }
      )
    </script>

    <style type="text/css">
      body {
        background: #20262E;
        padding: 20px;
        font-family: sans-serif;
      }
      #app {
        background: #fff;
        border-radius: 4px;
        padding: 20px;
        transition: all 0.2s;
        text-align: center;
      }
      #logo {
        width: 100px;
      }
      h2 {
        font-weight: bold;
        margin-bottom: 15px;
      }
      h1, h2 {
        font-weight: normal;
        margin-bottom: 15px;
      }
      a {
        color: #42b983;
      }
      img {
        width: 30%;
        margin: auto;
        display: block;
        margin-bottom: 10px;
      }
    </style>
  </body>
</html>
