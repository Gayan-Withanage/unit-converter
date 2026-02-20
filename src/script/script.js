const units = {
    length: {
        m: 1,
        km: 1000,
        cm: 0.01,
        mm: 0.001,
        mile: 1609.34,
        ft: 0.3048
    },
    mass: {
        kg: 1,
        g: 0.001,
        mg: 0.000001,
        lb: 0.453592,
        ton: 1000
    },
    time: {
        sec: 1,
        min: 60,
        hr: 3600,
        day: 86400
    },
    speed: {
        "m/s": 1,
        "km/h": 0.277778,
        mph: 0.44704
    }
};

function loadUnits() {
    const category = document.getElementById("category").value;
    const from = document.getElementById("fromUnit");
    const to = document.getElementById("toUnit");

    from.innerHTML = "";
    to.innerHTML = "";

    if (category === "temperature") {
        ["Celsius", "Fahrenheit", "Kelvin"].forEach(u => {
            from.add(new Option(u, u));
            to.add(new Option(u, u));
        });
        return;
    }

    for (let unit in units[category]) {
        from.add(new Option(unit, unit));
        to.add(new Option(unit, unit));
    }
}

function convert() {
    const value = parseFloat(document.getElementById("inputValue").value);
    const category = document.getElementById("category").value;
    const from = document.getElementById("fromUnit").value;
    const to = document.getElementById("toUnit").value;

    if (isNaN(value)) {
        document.getElementById("result").innerText = "Invalid input";
        return;
    }

    let result;

    if (category === "temperature") {
        result = convertTemperature(value, from, to);
    } else {
        result = (value * units[category][from]) / units[category][to];
    }

    document.getElementById("result").innerText =
        `${value} ${from} = ${result.toFixed(4)} ${to}`;
}

function convertTemperature(val, from, to) {
    if (from === to) return val;

    let celsius;
    if (from === "Celsius") celsius = val;
    if (from === "Fahrenheit") celsius = (val - 32) * 5/9;
    if (from === "Kelvin") celsius = val - 273.15;

    if (to === "Celsius") return celsius;
    if (to === "Fahrenheit") return celsius * 9/5 + 32;
    if (to === "Kelvin") return celsius + 273.15;
}

loadUnits();
