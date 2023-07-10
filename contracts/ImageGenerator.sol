// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface UtilsCollection {

    function random(string memory input) external pure returns (uint256);

    function pluck(uint256 tokenId, uint256 timestamp, uint256 maxValue, string memory prefix) external pure returns (uint256);

    function uint24ToHexStr(uint24 i, uint bytesCount) external pure returns (string memory);

    function generateColor(uint256 tokenId, uint256 timestamp) external pure returns (string memory);

    function uint8ToHexCharCode(uint8 i) external pure returns (uint8);

    function toString(uint256 value) external pure returns (string memory);

}

interface Trigonometry {
    function sin(uint _angle) external pure returns (int);

    function cos(uint _angle) external pure returns (int);
}

contract ImageGenerator {
    UtilsCollection _utils = UtilsCollection(0x9D7f74d0C41E726EC95884E0e97Fa6129e3b5E99);

string[] private _backgroundType = [
"M17,2,31.72243186433546,27.5,2.2775681356645414,27.5Z",
"M17,2,33.16796077701761,13.746711095625894,26.992349288972044,32.7532889043741,7.007650711027958,32.7532889043741,0.8320392229823916,13.746711095625889Z",
"M17,2,30.291135201956507,8.400673368401531,33.573774507091,22.782855877257347,24.37602356499849,34.316470754341125,9.623976435001506,34.316470754341125,0.4262254929089977,22.782855877257347,3.708864798043491,8.400673368401533Z",
"M17,2,27.92738936467117,5.977244466977373,33.741731801207536,16.047980979662185,31.72243186433546,27.5,22.81434243653637,34.97477455336044,11.185657563463632,34.97477455336045,2.2775681356645414,27.5,0.25826819879246443,16.04798097966218,6.072610635328829,5.977244466977375Z",
"M17,2,26.19089389674516,4.698689941869921,32.46374392102681,11.937944778967932,33.82696451197586,21.41935225064585,29.847742764022392,30.132632477069844,21.789453466304305,35.311380551446454,12.210546533695695,35.311380551446454,4.152257235977611,30.132632477069848,0.17303548802414426,21.419352250645847,1.5362560789731887,11.93794477896793,7.80910610325483,4.698689941869928Z",
"M17,2,24.900293924744066,3.9472475638954307,30.99072572019216,9.34289930557035,33.87605085966692,16.95087643565951,32.89527612565205,25.028283079723106,28.273085190093518,31.724682718908717,21.06836629288848,35.506010896242884,12.931633707111516,35.506010896242884,5.72691480990648,31.724682718908717,1.1047238743479504,25.02828307972311,0.12394914033308169,16.95087643565952,3.0092742798078476,9.342899305570342,9.099706075255925,3.947247563895438Z",
"M17,2,21.11449676604731,13.336881039375367,33.16796077701761,13.746711095625894,23.657395614066075,21.163118960624633,26.992349288972044,32.7532889043741,17,26,7.007650711027958,32.7532889043741,10.342604385933925,21.163118960624633,0.8320392229823916,13.746711095625889,12.885503233952686,13.336881039375369Z",
"M17,2,20.03718617382291,12.693217924683067,30.291135201956507,8.400673368401531,23.824495385272765,17.4423534623058,33.573774507091,22.782855877257347,22.472820377276207,23.364428613011135,24.37602356499849,34.316470754341125,17,26,9.623976435001506,34.316470754341125,11.527179622723791,23.364428613011135,0.4262254929089977,22.782855877257347,10.175504614727236,17.442353462305793,3.708864798043491,8.400673368401533,13.962813826177092,12.693217924683067Z",
"M17,2,19.39414100327968,12.422151654498641,27.92738936467117,5.977244466977373,23.062177826491073,15.5,33.741731801207536,16.047980979662185,23.893654271085456,20.215537243668514,31.72243186433546,27.5,21.499513267805774,24.362311101832844,22.81434243653637,34.97477455336044,17,26,11.185657563463632,34.97477455336045,12.500486732194226,24.362311101832844,2.2775681356645414,27.5,10.106345728914544,20.21553724366851,0.25826819879246443,16.04798097966218,10.93782217350893,15.5,6.072610635328829,5.977244466977375,14.605858996720315,12.422151654498641Z",
"M17,2,18.972127897890008,12.283549184698519,26.19089389674516,4.698689941869921,22.29024702047981,14.415974862383006,32.46374392102681,11.937944778967932,23.928750093166528,18.003796132087004,33.82696451197586,21.41935225064585,23.367423967481628,21.907905091013205,29.847742764022392,30.132632477069844,20.78448572218918,24.88877472981827,21.789453466304305,35.311380551446454,17,26,12.210546533695695,35.311380551446454,13.215514277810819,24.88877472981827,4.152257235977611,30.132632477069848,10.632576032518372,21.907905091013205,0.17303548802414426,21.419352250645847,10.07124990683347,18.003796132087004,1.5362560789731887,11.93794477896793,11.70975297952019,14.415974862383006,7.80910610325483,4.698689941869928,15.027872102109992,12.283549184698519Z",
"M17,2,18.675209650012903,12.203407278017636,24.900293924744066,3.9472475638954307,21.641858607685567,13.760424762802293,30.99072572019216,9.34289930557035,23.545113698797905,16.51776579070225,33.87605085966692,16.95087643565951,23.948962118686378,19.84375676178726,32.89527612565205,25.028283079723106,22.760887061255595,22.976453227118093,28.273085190093518,31.724682718908717,20.253062204306378,25.19819217957247,21.06836629288848,35.506010896242884,17,26,12.931633707111516,35.506010896242884,13.74693779569362,25.19819217957247,5.72691480990648,31.724682718908717,11.239112938744405,22.976453227118093,1.1047238743479504,25.02828307972311,10.051037881313622,19.843756761787258,0.12394914033308169,16.95087643565952,10.454886301202095,16.517765790702253,3.0092742798078476,9.342899305570342,12.358141392314431,13.760424762802295,9.099706075255925,3.947247563895438,15.324790349987103,12.203407278017634Z"
"M 0, 19 a 17,17 0 1,0 34,0 a 17,17 0 1,0 -34,0",
"M 0 0 H 34 V 38 H 0 L 0 0"
];

string[] private _backgroundName = [
"triangle",
"pentagon",
"heptagon",
"nonagon",
"hendecagon",
"tridecagon",
"pentagram",
"heptagram",
"nonagram",
"hendecagram",
"tridecagram",
"circle",
"square"
];

string[] private _opacity = [
"1",
"0.9",
"0.8",
"0.7",
"0.6",
"0.5",
"0.4",
"0.3",
"0.2",
"0.1",
"0.05",
"0.01",
"0.0",
];

string[] private _animationTransform = [
'<animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 17 19" to="-360 17 19" repeatCount="indefinite" dur="5s"/>',
'<animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 17 19" to="-360 17 19" repeatCount="indefinite" dur="5s"/>',
'<animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 17 19" to="-360 17 19" repeatCount="indefinite" dur="5s"/>',
'<animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 17 19" to="-360 17 19" repeatCount="indefinite" dur="5s"/>',
'<animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 17 19" to="-360 17 19" repeatCount="indefinite" dur="5s"/>',
'<animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 17 19" to="-360 17 19" repeatCount="indefinite" dur="5s"/>',
'<animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 17 19" to="-360 17 19" repeatCount="indefinite" dur="5s"/>',
'<animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 17 19" to="-360 17 19" repeatCount="indefinite" dur="5s"/>',
'<animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 17 19" to="-360 17 19" repeatCount="indefinite" dur="5s"/>',
'<animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 17 19" to="-360 17 19" repeatCount="indefinite" dur="5s"/>',
'<animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 17 19" to="-360 17 19" repeatCount="indefinite" dur="5s"/>',
'<animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 17 19" to="-360 17 19" repeatCount="indefinite" dur="5s"/>',
'<animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 17 19" to="-360 17 19" repeatCount="indefinite" dur="5s"/>'
];

uint256[] private _animationDuration = [
1,
2,
3,
4
];

uint256[] private _colorsCount = [
1,
2,
3,
4
];

string[] private _color = [
"solid",
"horizontal",
"vertical",
"radial"
];

function _getHeader(uint256 tokenId) public view returns (string memory) {
string[3] memory parts;
parts[
0
] = '<svg xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cc="http://creativecommons.org/ns#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:svg="http://www.w3.org/2000/svg" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="34mm" height="38mm" viewBox="0 0 34 38" version="1.1" id="bpxLogoNft';

parts[1] = _utils.toString(tokenId);

parts[2] = '">';

return string(
abi.encodePacked(
parts[0],
parts[1],
parts[2]
)
);
}

function _shouldAnimate(uint256 tokenId, uint256 timestamp, string memory sufix) public view returns (bool) {
return uint24(_utils.pluck(tokenId, timestamp, 1, string(abi.encodePacked("animate", sufix)))) == 1;
}

function _getBackgroundType(uint256 tokenId, uint256 timestamp) public view returns (string memory) {
return _backgroundType[uint24(_utils.pluck(tokenId, timestamp, 3, "background_type"))];
}

function _getColor(uint256 tokenId, uint256 timestamp, string memory sufix) public view returns (string memory) {
return _color[uint24(_utils.pluck(tokenId, timestamp, 3, string(abi.encodePacked("color", sufix))))];
}

function _getOpacity(uint256 tokenId, uint256 timestamp, string memory sufix) public view returns (string memory) {
return _opacity[uint24(_utils.pluck(tokenId, timestamp, 3, string(abi.encodePacked("opacity", sufix))))];
}

function _getAnimationType(uint256 tokenId, uint256 timestamp) public view returns (string memory) {
return _animation[uint24(_utils.pluck(tokenId, timestamp, 3, "animation_type"))];
}

function _getAnimationDuration(uint256 tokenId, uint256 timestamp) public view returns (uint256) {
return _animationDuration[uint24(_utils.pluck(tokenId, timestamp, 3, "animation_duration"))];
}

function _getColorsCount(uint256 tokenId, uint256 timestamp, string memory sufix) public view returns (uint256) {
return _colorsCount[uint24(_utils.pluck(tokenId, timestamp, 3, string(abi.encodePacked("colors_count", sufix))))];
}

function _generatePolygon(){

}

function _polarToCartesian(uint256 centerX, uint256 centerY, uint256 radius, uint256 angleInDegrees)  public view returns (uint256 x, uint256 y) {
const angleInRadians = (angleInDegrees - 90) * Math.PI / 180.0;
return (centerX + (radius * _trig.cos(angleInRadians)),
centerY + (radius * _trig.sin(angleInRadians)));
}


function polygon(uint256 centerX, uint256 centerY, uint256 radius, uint256 angleInDegrees) {
const degreeIncrement = 360 / (points);
const d = new Array(points).fill('foo').map((p, i) => {
const point = polarToCartesian(centerX, centerY, radius, degreeIncrement * i);
return `${point.x}, ${point.y}`;
});
return `M${d}Z`;
}

function _getDefsSection(uint256 tokenId, uint256 timestamp) public view returns (string memory) {


string[3] memory parts;
parts[
0
] = '<svg xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cc="http://creativecommons.org/ns#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:svg="http://www.w3.org/2000/svg" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="34mm" height="38mm" viewBox="0 0 34 38" version="1.1" id="bpxLogoNft';

parts[1] = _utils.toString(tokenId);

parts[2] = '">';

return string(
abi.encodePacked(
parts[0],
parts[1],
parts[2]
)
);

}

function generateColor(uint256 tokenId, uint256 timestamp) public view returns (string memory){
return _utils.generateColor(tokenId, timestamp);
}
}