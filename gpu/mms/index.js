/**
 * @license
 * Copyright 2019 Google LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * =============================================================================
 */


let net;

function toggleImage(id,primary,secondary) {
    console.log('Toggling image ...');
    src=document.getElementById(id).src;
    if (src.match(primary)) {
      document.getElementById(id).src=secondary;
    } else {
      document.getElementById(id).src=primary;
    }
    console.log('Analyzing new image ...');
    app();
}

async function app() {
  console.log('Loading cocoSSD ...');

  // Load the model.
  net = await cocoSsd.load();
  console.log('Successfully loaded model');

  // Make a prediction through the model on our image.
  const imgEl = document.getElementById('img');
  const result = await net.detect(imgEl);
  console.log(result);
}

app();

//https://www.tensorflow.org/js/models/
