Reveal.initialize({
    center: true,
    hash: true,
    controls: false,
    transitionSpeed: 'fast',
    slideNumber: false,
    width: 1920,
    height: 1080,
    plugins: [RevealHighlight],
    autoAnimateStyles: [
        'opacity',
        'color',
        'background-color',
        'padding',
        'font-size',
        'line-height',
        'letter-spacing',
        'border-width',
        'border-color',
        'border-radius',
        'outline',
        'outline-offset'
    ]
});

// fill in ENaC spans

document.querySelectorAll('span.alpha').forEach(s => {
    s.classList.add('greek-letter')
    s.innerHTML = '&alpha;';
});
document.querySelectorAll('span.beta').forEach(s => {
    s.classList.add('greek-letter')
    s.innerHTML = '&beta;';
});
document.querySelectorAll('span.gamma').forEach(s => {
    s.classList.add('greek-letter')
    s.innerHTML = '&gamma;';
});
document.querySelectorAll('span.cko').forEach(s => {
    s.innerHTML = 'CKO';
})
document.querySelectorAll('span.ckodeg').forEach(s => {
    s.innerHTML = 'CKO/DEG';
})
document.querySelectorAll('span.asic').forEach(s => {
    s.innerHTML = 'ASIC';
})
document.querySelectorAll('span.trypsin').forEach(s => {
    s.innerHTML = 'trypsinized mouse'
})
document.querySelectorAll('span.mouse').forEach(s => {
    s.innerHTML = 'mouse uncleaved'
})


// play movies

function playUntil(movie, stopTime) {
    movie.play();
    window.setTimeout(() => {
        movie.pause();
    }, stopTime)
}

const overviewMovie = document.querySelector('#overview-video');
const cartoonOverview = document.querySelector('#cartoon-overview');
const bilayerPan = document.querySelector('#bilayer-pan-video');
const bilayerEnac = document.querySelector('#bilayer-enac-video');
const singleResidue = document.querySelector('#single-residue-video');
const residueChain = document.querySelector('#residue-chain-video');
const ecdTurnVideo = document.querySelector('#ecd-turn-video');
const micelleOverviewVideo = document.querySelector('#micelle-tilt_overview');
const micelleSugarOne = document.querySelector('#sugar-1');
const micelleSugarTwo = document.querySelector('#sugar-2');
const asicTransition = document.querySelector('#asic-transition');
const asicZoom = document.querySelector('#asic-zoom');

Reveal.on('fragmentshown', event => {
    switch (event.fragment.id) {
        case 'play-subunit-overview':
            overviewMovie.currentTime = 0;
            overviewMovie.play();
            break;
        case 'cartoon-overview':
            cartoonOverview.currentTime = 0;
            cartoonOverview.play();
            break;
        case 'bilayer-pan-video':
            bilayerPan.currentTime = 0;
            bilayerPan.play();
            break;
        case 'bilayer-enac-video':
            bilayerEnac.currentTime = 0;
            bilayerEnac.play();
            break;
        case 'single-residue-video':
            singleResidue.currentTime = 0;
            singleResidue.play();
            break;
        case 'residue-chain-video':
            residueChain.currentTime = 0;
            residueChain.play();
            break;
        case 'ecd-turn':
            ecdTurnVideo.currentTime = 0;
            ecdTurnVideo.play();
            break;
        case 'play-micelle-overview':
            micelleOverviewVideo.currentTime = 0;
            micelleOverviewVideo.play();
            break;
        case 'sugar-1':
            micelleSugarOne.currentTime = 0;
            micelleSugarOne.play();
            break;
        case 'sugar-2':
            micelleSugarTwo.currentTime = 0;
            micelleSugarTwo.play();
            break;
        case 'asic-transition':
            asicTransition.currentTime = 0;
            asicTransition.play();
            break;
        case 'asic-zoom':
            asicZoom.currentTime = 0;
            asicZoom.play();
            break;
    }
})

Reveal.on('fragmenthidden', event => {
    switch (event.fragment.id) {
        case 'play-subunit-overview':
            overviewMovie.currentTime = 0;
            overviewMovie.pause();
            break;
        case 'cartoon-overview':
            cartoonOverview.currentTime = 0;
            cartoonOverview.pause();
            break;
        case 'bilayer-pan-video':
            bilayerPan.currentTime = 0;
            bilayerPan.pause();
            break;
        case 'bilayer-enac-video':
            bilayerEnac.currentTime = 0;
            bilayerEnac.pause();
            break;
        case 'single-residue-video':
            singleResidue.currentTime = 0;
            singleResidue.pause();
            break;
        case 'residue-chain-video':
            residueChain.currentTime = 0;
            residueChain.pause();
            break;
        case 'ecd-turn':
            ecdTurnVideo.currentTime = 0;
            ecdTurnVideo.pause();
            break;
        case 'play-micelle-overview':
            micelleOverviewVideo.currentTime = 0;
            micelleOverviewVideo.pause();
            break;
        case 'sugar-1':
            micelleSugarOne.currentTime = 0;
            micelleSugarOne.pause();
            micelleOverviewVideo.currentTime = 0;
            micelleOverviewVideo.play();
            break;
        case 'sugar-2':
            micelleSugarTwo.currentTime = 0;
            micelleSugarTwo.pause();
            micelleSugarOne.currentTime = 0;
            micelleSugarOne.play();
            break;
        case 'asic-transition':
            asicTransition.currentTime = 0;
            asicTransition.pause();
            break;
        case 'asic-zoom':
            asicZoom.currentTime = 0;
            asicZoom.pause();
            asicTransition.currentTime = 0;
            asicTransition.play();
            break;
    }
})

bilayerPan.addEventListener('ended', () => {
    Reveal.nextFragment();
})

asicTransition.addEventListener('ended', () => {
    Reveal.nextFragment();
})

// slide number hiding from https://stackoverflow.com/questions/31146251/hide-slide-number-on-title-page

Reveal.addEventListener('slidechanged', (event) => {
    const isSnOn = (event.currentSlide.dataset.hideSlideNumber !== 'true' ? 'c/t' : false);
    Reveal.configure({ slideNumber: isSnOn, progress: isSnOn });
});

function makeWiggleAnimated(selectedSpan) {
    const delayAmount = 75; // in milliseconds
    const stringToAnimate = selectedSpan.innerHTML;
    selectedSpan.innerHTML = '';
    var delayIndex = 0
    for (char of stringToAnimate) {
        let newSpan = document.createElement('span');
        newSpan.innerText = char;
        console.log(delayAmount * delayIndex);
        newSpan.style.animationDelay = `${delayAmount * delayIndex}ms`;
        newSpan.style.display = 'inline-block';
        newSpan.classList.add('wiggle-char');
        selectedSpan.appendChild(newSpan);
        delayIndex += 1;
    }
}

document.querySelectorAll('.animate-wiggle').forEach(makeWiggleAnimated);