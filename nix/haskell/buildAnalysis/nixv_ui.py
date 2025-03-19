import json

with open("command_state.json", "r") as f:
    d = json.load(f)
    with open("command_time.html", "w") as file:
        file.write(
            """
<!DOCTYPE html>
<html>

<head>
    <title>Nixv Analytics</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet"
        integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous">

</head>

<body>
    <div class="container">
        <div class="row mx-auto p-3 m-3">
            <div class="col-6">
                <div class="p-4 row" style="width: 400px;height: 400px;">
                    <div class="col-12">
                        <strong> Duration : </strong>
                        <p id="totalTimeTaken"> </p>
                    </div>
                    <div class="col-12">
                        <strong> Required Derivations : </strong>
                        <p id="requiredDevations"> </p>
                    </div>
                    <div class="col-12">
                        <strong> Build Derivations : </strong>
                        <p id="buildDerivations"> </p>
                    </div>
                    <div class="col-12">
                        <strong> Derivations Substituted : </strong>
                        <p id="drvSubstitute"> </p>
                    </div>
                </div>
            </div>
            <div class="col-6">
                <canvas id="doughnutChart" width="500" height="500"></canvas>
            </div>
        </div>
    </div>
    <div class="container">
        <div class="accordion align-self-center" id="accordionPackages"> </div>
    </div>
    <script>
        var data = """
            + json.dumps(d)
            + """;
        function groupByPathAndPkgName(data) {
            const allowed = [, "act_file_transfer", "act_substitute", "act_copy_path", "act_build"];
            const stageNames = Object.keys(data).filter(key => allowed.includes(key));

            let required_pkgs = data["required_derivations"].map(e => {
                let drv = e.replace("/nix/store/", "");
                const hyphenOccurrences = (drv.match(/-/g) || []).length;
                const firstHyphenIndex = drv.indexOf('-');
                const firstPart = drv.slice(0, firstHyphenIndex);
                const remainingPart = drv.slice(firstHyphenIndex + 1);
                let d = {
                    "drvHash": firstPart,
                    "pkgName": remainingPart,
                    "duration": 0,
                    "events": {
                        "act_copy_path": [],
                        "act_file_transfer": [],
                        "act_build": [],
                        "act_substitute": [],
                    }
                }
                stageNames.map((e) => {
                    if (e == "act_copy_path" || e == "act_build" || e == "act_substitute") {
                        d.events[e].push(data[e].map(ee => {
                            if (d.pkgName === ee.package_name) {
                                d.duration += (ee.end.secs_since_epoch - ee.start.secs_since_epoch) + (ee.end.nanos_since_epoch - ee.start.nanos_since_epoch) * 1e-9;
                                return ee;
                            }
                        }).filter(function (element) {
                            return element !== undefined;
                        }))
                    } else if (e == "act_file_transfer") {
                        d.events[e].push(data[e].map(ee => {
                            const match = ee.file.match(/\/([^/]+)\.narinfo/);
                            const desiredPart = match ? match[1] : null;
                            if (desiredPart != null && d.drvHash === desiredPart) {
                                d.duration += (ee.end.secs_since_epoch - ee.start.secs_since_epoch) + (ee.end.nanos_since_epoch - ee.start.nanos_since_epoch) * 1e-9;
                                return ee;
                            }
                        }).filter(function (element) {
                            return element !== undefined;
                        }))
                    }
                }).filter(function (element) {
                    return element !== undefined;
                });
                d.duration = Math.round((d.duration + Number.EPSILON) * 100) / 100
                return d;
            });
            let h = "";
            required_pkgs.sort((a, b) => b.duration - a.duration).map(e => generateAccordionItem(e)).forEach(v => h += v);
            document.getElementById("accordionPackages").innerHTML = h;
        }
        function getTotalTime(d, label) {
            let t = 0;
            d.map((e) => {
                let durationSeconds = e.end.secs_since_epoch - e.start.secs_since_epoch;
                let durationNanoseconds = e.end.nanos_since_epoch - e.start.nanos_since_epoch;
                return durationSeconds + durationNanoseconds * 1e-9;
            }).forEach(num => {
                t += num;
            });
            return t
        }
        function generateDoughnutChart(moduleData) {
            const allowed = ["act_build_waiting", "act_post_build_hook", "act_query_path_info", "act_build", "act_unknown", "act_copy_paths", "act_builds", "act_build_waiting", "act_realise", "act_copy_path", "act_file_transfer", "act_substitute"];
            const stageNames = Object.keys(moduleData).filter(key => allowed.includes(key));
            const datasets = stageNames.map((stageName) => {
                let x = getTotalTime(moduleData[stageName], stageName);
                return x;
            });
            let totalTime = (moduleData.end.secs_since_epoch - moduleData.start.secs_since_epoch) + (moduleData.end.nanos_since_epoch - moduleData.start.nanos_since_epoch) * 1e-9;
            const ctx = document.getElementById("doughnutChart").getContext('2d');
            document.getElementById("totalTimeTaken").innerText = totalTime + " seconds";
            document.getElementById("requiredDevations").innerText = moduleData.required_derivations.length;
            document.getElementById("buildDerivations").innerText = moduleData.act_build.length;
            const uniqueDrv = data.act_substitute.map((e) => e.store_path).sort().filter(function (item, pos, ary) {
                return !pos || item != ary[pos - 1];
            });
            document.getElementById("drvSubstitute").innerText = uniqueDrv.length;
            const doughnutChart = new Chart(ctx, {
                type: 'doughnut',
                data: {
                    labels: stageNames,
                    datasets: [{
                        data: datasets,
                        borderColor: 'white',
                        backgroundColor: ["rgb(178, 190, 181)",
                            "rgb(115, 147, 179)",
                            "rgb(54, 69, 79)",
                            "rgb(169, 169, 169)",
                            "rgb(96, 130, 182)",
                            "rgb(128, 128, 128)",
                            "rgb(129, 133, 137)",
                            "rgb(211, 211, 211)",
                            "rgb(137, 148, 153)",
                            "rgb(229, 228, 226)",
                            "rgb(138, 154, 91)",
                            "rgb(192, 192, 192)",
                            "rgb(112, 128, 144)",
                            "rgb(132, 136, 132)",
                            "rgb(113, 121, 126)"],
                        hoverOffset: 4
                    }]
                },
                options: {
                    responsive: false,
                    cutout: '55%',
                    plugins: {
                    }
                },
            });
        }

        function generateAccordionItem(i) {
            let accordionHtml = '<div class="row">';
            for (var eventType in i.events) {
                if (i.events[eventType][0].length != 0)
                    accordionHtml += generateEventHtml(eventType, i.events[eventType]);
            }
            accordionHtml = accordionHtml + "</div>";

            return (
                '<div class="accordion-item">' +
                '<h2 class="accordion-header" id="' + (i.drvHash).replace(/[0-9-\.]/g, "") + '">' +
                '<button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#' + (i.pkgName).replace(/[0-9-\.]/g, "") + '" aria-expanded="false" aria-controls="' + (i.pkgName).replace(/[0-9-\.]/g, "") + '">' +
                i.pkgName + " - " + i.duration + " seconds" +
                '</button>' +
                "</h2>" +
                '<div id="' + (i.pkgName).replace(/[0-9-\.]/g, "") + '" class="accordion-collapse collapse" aria-labelledby="' + (i.drvHash).replace(/[0-9-\.]/g, "") + '" data-bs-parent="#accordionPackages">' +
                '<div class="accordion-body">' + accordionHtml +
                '</div>' +
                '</div>' +
                '</div>');
        }

        function generateEventHtml(eventType, eventDetails) {
            if (eventDetails != []) {
                var eventHtml = '<div class="card p-3 m-3 col" style="width: 33rem;">' +
                    '<div class="card-header">' + eventType + '</div>' +
                    '<div class="card-body">';

                eventHtml += '<ul class="list-group">';

                for (var i = 0; i < eventDetails.length; i++) {
                    for (var j = 0; j < eventDetails[i].length; j++) {
                        eventHtml += '<li class="list-group-item">';

                        for (var key in eventDetails[i][j]) {
                            if (key != "end" && key != "start")
                                eventHtml += '<strong>' + key + ':</strong> ' + eventDetails[i][j][key] + '<br>';
                        }
                        let eventItemTime = (eventDetails[i][j].end.secs_since_epoch - eventDetails[i][j].start.secs_since_epoch) + (eventDetails[i][j].end.nanos_since_epoch - eventDetails[i][j].start.nanos_since_epoch) * 1e-9;
                        eventHtml += '<strong>' + "duration" + ':</strong> ' + Math.round((eventItemTime + Number.EPSILON) * 100000) / 100000 + ' seconds <br>'

                        eventHtml += '</li>';
                    }
                }

                eventHtml += '</ul>';
                eventHtml += '</div></div>';
            } else {
                eventHtml = '';
            }
            return eventHtml;
        }
        window.onload = function () {
            groupByPathAndPkgName(data);
            generateDoughnutChart(data);
        };
    </script>
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.9.2/dist/umd/popper.min.js"
        integrity="sha384-IQsoLXl5PILFhosVNubq5LC7Qb9DXgDA9i+tQ8Zj3iwWAwPtgFTxbJ8NT4GN1R8p"
        crossorigin="anonymous"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.min.js"
        integrity="sha384-cVKIPhGWiC2Al4u+LWgxfKTRIcfu0JTxR+EQDz/bgldoEyl4H0zUF0QKbrJ0EcQF"
        crossorigin="anonymous"></script>
</body>

</html>
"""
        )
