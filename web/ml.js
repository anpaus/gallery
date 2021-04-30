function learnLinear(input) {
    return 12+20+input;
}
function myFunction() {

    const img = document.getElementById('img');

    img.onload = function(){
        console.log('Image loaded, size ${img.width}x${img.height}');
    }
    img.onerror = function(){
        console.log(`Error, size ${img.width}x${img.height}`);
    }
    console.log('hello');
}

async function runPrediction(){
            const model=tf.sequential();
            model.add(
                tf.layers.dense({
                    units:1,
                    inputShape:[1],
                    bias: true
                })
            );

            model.compile({
                loss:'meanSquaredError',
                optimizer: 'sgd',
                metrics: ['mse']
            });

            const xs = tf.tensor1d([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
            const ys = tf.tensor1d([2, 5, 8, 12, 14, 18, 21, 23, 26, 29]);

            await model.fit(xs, ys, {epochs:100});
            var p = model.predict(tf.tensor1d([100])).dataSync();
	        return p[0];
}

async function classifyImage() {

    const img = document.getElementById('img');

    console.log('Loading mobilenet..' + document.getElementById('img').src);
    console.log('Loading mobilenet..' + document.getElementById('img').width);
    console.log('Loading mobilenet..' + document.getElementById('img').height);
    console.log('Loading mobilenet..' + document.getElementById('img').complete);
    // LOAD MOBILENET MODEL
    const model = await mobilenet.load();
    console.log('Successfully loaded model');

    // CLASSIFY THE IMAGE
    let predictions = await model.classify(img);
    console.log('Pred >>>', predictions);

    return predictions
}

