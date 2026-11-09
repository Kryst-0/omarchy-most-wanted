import QtQuick
import qs.Commons as Commons

Item {
    id: root
    property var car: ({name: "BMW M3 GTR", shape: "coupe", color: "#d5d9dd", stripe: "#285ba8", wing: true})
    property bool driving: true
    property bool miniature: false
    property real phase: 0
    readonly property bool motion: driving && visible && Commons.Style.duration(200) > 0
    clip: true

    // One short linear cycle gives continuous road motion and respects reduced motion.
    NumberAnimation on phase {
        from: 0; to: 1
        duration: Commons.Style.duration(240)
        loops: Animation.Infinite
        running: root.motion
    }
    Canvas {
        id: scene
        anchors.fill: parent
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        Connections {
            target: root
            function onPhaseChanged() { scene.requestPaint() }
            function onCarChanged() { scene.requestPaint() }
        }
        onPaint: {
            var c = getContext("2d"); c.reset();
            var w=width, h=height, ground=h*.80;
            if (!root.miniature) {
                var sky=c.createLinearGradient(0,0,0,h);
                sky.addColorStop(0,"#141b27"); sky.addColorStop(1,"#65716c");
                c.fillStyle=sky; c.fillRect(0,0,w,h);
                c.fillStyle="#d6bb70"; c.beginPath(); c.arc(w*.79,h*.23,h*.10,0,Math.PI*2); c.fill();
                for(var i=-1;i<18;i++) {
                    var bx=i*43-root.phase*7, bh=24+((i+20)*37%57);
                    c.fillStyle="#26313a"; c.fillRect(bx,ground-bh-20,32,bh);
                    c.fillStyle="#a79868";
                    for(var j=0;j<3;j++) c.fillRect(bx+7+j*8,ground-bh-10,3,3);
                }
                c.fillStyle="#5e6659"; c.fillRect(0,ground-23,w,23);
                c.fillStyle="#b8b3a0"; c.fillRect(0,ground-13,w,4);
            }
            c.fillStyle=root.miniature ? "#262a31" : "#30343b";
            c.fillRect(0,ground-8,w,h-ground+8);
            c.fillStyle="#d9c77e";
            var step=root.miniature ? 18 : 60;
            for(var k=-1;k<w/step+1;k++) c.fillRect(k*step-root.phase*step,ground+h*.11,step*.48,root.miniature?1:2);
            var cw=root.miniature ? w*.83 : Math.min(w*.70,340), ch=cw*.34;
            c.save(); c.translate((w-cw)/2,ground-ch); c.scale(cw/300,ch/102);
            var car=root.car, shape=car.shape;
            var hatch=shape==="hatch", sedan=shape==="sedan"||shape==="rally", low=shape==="super"||shape==="wedge";
            var muscle=shape==="muscle"||shape==="classic", porsche=shape==="porsche";
            var roofY=low?35:hatch?11:sedan?13:muscle?20:22;
            var roofL=hatch?57:low?117:porsche?87:muscle?83:89;
            var roofR=hatch?155:low?174:shape==="long"?161:184;
            c.fillStyle="#101318"; c.beginPath(); c.ellipse(151,96,139,5,0,0,Math.PI*2); c.fill();
            function path(points) { c.beginPath(); c.moveTo(points[0][0],points[0][1]); for(var t=1;t<points.length;t++) c.lineTo(points[t][0],points[t][1]); c.closePath(); }
            var body=[[10,72],[17,hatch?37:53],[hatch?43:59,48],[roofL,roofY],[roofR,roofY],[low?224:221,49],[278,55],[293,66],[290,85],[12,85]];
            path(body);
            var paint=c.createLinearGradient(0,roofY,0,90); paint.addColorStop(0,Qt.lighter(car.color,1.3).toString()); paint.addColorStop(.6,car.color); paint.addColorStop(1,Qt.darker(car.color,1.8).toString());
            c.fillStyle=paint; c.fill(); c.strokeStyle="#171c24"; c.lineWidth=2; c.stroke();
            path([[hatch?49:70,48],[roofL+7,roofY+6],[roofR-7,roofY+6],[205,48]]);
            c.fillStyle="#172c3c"; c.fill(); c.strokeStyle="#8fabb4"; c.lineWidth=1; c.stroke();
            c.fillStyle=car.color; c.fillRect(sedan?123:132,roofY+3,5,48-roofY);
            c.strokeStyle="rgba(0,0,0,.40)"; c.lineWidth=1; c.beginPath(); c.moveTo(137,50); c.lineTo(137,79); c.lineTo(205,79); c.lineTo(209,51); c.stroke();
            if(sedan) { c.beginPath(); c.moveTo(78,51); c.lineTo(78,78); c.lineTo(132,78); c.stroke(); }
            if(car.stripe) {
                path([[26,63],[130,56],[183,65],[263,57],[257,68],[171,76],[116,66],[28,74]]); c.fillStyle=car.stripe; c.fill();
                if(car.name.indexOf("BMW")>=0) { path([[55,51],[75,51],[154,83],[126,83]]); c.fill(); }
            }
            c.fillStyle="#111820"; c.fillRect(15,82,275,5);
            c.fillStyle="#e8f0d5"; c.fillRect(268,57,16,6);
            c.fillStyle="#df453d"; c.fillRect(16,55,8,9);
            c.fillStyle="#15212b"; c.fillRect(277,72,14,7);
            c.fillStyle="#d2d7d5"; c.fillRect(172,52,13,2);
            if(car.wing) { c.fillStyle="#1d252f"; c.fillRect(25,31,4,23); c.fillRect(14,29,49,5); }
            // Model cues: side intakes, rally scoop, classic vents, Porsche rear engine grille.
            c.fillStyle="#19222c";
            if(low||shape==="small") { path([[193,57],[219,52],[208,74],[197,74]]); c.fill(); }
            if(shape==="rally") c.fillRect(228,46,24,4);
            if(shape==="long") for(var v=0;v<3;v++) c.fillRect(214+v*7,56,3,13);
            if(porsche) for(var g=0;g<4;g++) c.fillRect(31+g*5,47,2,7);
            if(shape==="classic") { c.fillStyle="#b6bcc1"; c.fillRect(258,58,26,4); }
            for(var ax=0;ax<2;ax++) {
                var wx=ax===0?65:239;
                c.fillStyle="#10141b"; c.beginPath(); c.arc(wx,82,22,0,Math.PI*2); c.fill();
                c.fillStyle="#66717c"; c.beginPath(); c.arc(wx,82,15,0,Math.PI*2); c.fill();
                c.save(); c.translate(wx,82); c.rotate(root.phase*Math.PI*2);
                c.strokeStyle="#d0d7dc"; c.lineWidth=3;
                for(var sp=0;sp<5;sp++) { c.rotate(Math.PI*2/5); c.beginPath(); c.moveTo(0,0); c.lineTo(12,0); c.stroke(); }
                c.restore(); c.fillStyle="#151d25"; c.beginPath(); c.arc(wx,82,4,0,Math.PI*2); c.fill();
            }
            c.restore();
        }
    }
}
