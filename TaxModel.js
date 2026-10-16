.pragma library

var TAX_YEARS = {
  2025: {
    bands: [
      { max: 38441, rate: 0.0817 },
      { max: 76817, rate: 0.3748 },
      { max: Infinity, rate: 0.495 }
    ],
    socialCap: 38440,
    generalCredit: { max: 3068, start: 28406, rate: 0.06337, end: 76817 },
    laborCredit: {
      first: 12169, second: 26288, third: 43071, end: 129078,
      firstRate: 0.08053, secondBase: 980, secondRate: 0.3003,
      thirdBase: 5220, thirdRate: 0.02258, fourthBase: 5599,
      phaseOutRate: 0.0651, lowWageThreshold: 8566
    },
    elderCredit: { max: 2035, start: 45308, rate: 0.15, end: 58875 },
    socialRate: 0.2765,
    aowSocialRate: 0.0975,
    rulingThreshold: { normal: 46660, young: 35468, research: 0 },
    rulingCap: 246000
  },
  2026: {
    bands: [
      { max: 38883, rate: 0.081 },
      { max: 78426, rate: 0.3756 },
      { max: Infinity, rate: 0.495 }
    ],
    socialCap: 38882,
    generalCredit: { max: 3115, start: 29736, rate: 0.06398, end: 78426 },
    laborCredit: {
      first: 11965, second: 25845, third: 45592, end: 132920,
      firstRate: 0.08324, secondBase: 996, secondRate: 0.31009,
      thirdBase: 5300, thirdRate: 0.0195, fourthBase: 5685,
      phaseOutRate: 0.0651, lowWageThreshold: 8714
    },
    elderCredit: { max: 2067, start: 46002, rate: 0.15, end: 59782 },
    socialRate: 0.2765,
    aowSocialRate: 0.0975,
    rulingThreshold: { normal: 48013, young: 36497, research: 0 },
    rulingCap: 262000
  }
};

function roundMoney(amount) {
  return Math.round((Number(amount) + Number.EPSILON) * 100) / 100;
}

function parseAmount(value) {
  var text = String(value === undefined || value === null ? "" : value)
    .replace(/[€\s]/g, "");
  if (!text) return 0;

  var comma = text.lastIndexOf(",");
  var dot = text.lastIndexOf(".");
  if (comma >= 0 && dot >= 0) {
    if (comma > dot) text = text.replace(/\./g, "").replace(",", ".");
    else text = text.replace(/,/g, "");
  } else if (comma >= 0) {
    var commaParts = text.split(",");
    if (commaParts.length > 2 || commaParts[commaParts.length - 1].length === 3)
      text = text.replace(/,/g, "");
    else
      text = text.replace(",", ".");
  } else if (dot >= 0) {
    var dotParts = text.split(".");
    if (dotParts.length > 2 || dotParts[dotParts.length - 1].length === 3)
      text = text.replace(/\./g, "");
  }

  var amount = Number(text);
  return isFinite(amount) && amount >= 0 ? Math.min(amount, 10000000) : 0;
}

function progressiveTax(amount, bands) {
  var income = Math.max(0, Number(amount) || 0);
  var tax = 0;
  var lower = 0;

  for (var i = 0; i < bands.length; i++) {
    var upper = bands[i].max;
    var slice = Math.max(0, Math.min(income, upper) - lower);
    tax += slice * bands[i].rate;
    if (income <= upper) break;
    lower = upper;
  }

  return roundMoney(tax);
}

function generalCredit(income, data, multiplier) {
  if (income >= data.end) return 0;
  var credit = income <= data.start
    ? data.max
    : data.max - data.rate * (income - data.start);
  return roundMoney(Math.max(0, credit) * multiplier);
}

function laborCredit(income, data, multiplier) {
  if (income < data.lowWageThreshold / Math.max(multiplier, 0.000001) || income >= data.end)
    return 0;

  var credit;
  if (income <= data.first) {
    credit = income * data.firstRate;
  } else if (income <= data.second) {
    credit = data.secondBase + (income - data.first) * data.secondRate;
  } else if (income <= data.third) {
    credit = data.thirdBase + (income - data.second) * data.thirdRate;
  } else {
    credit = data.fourthBase - (income - data.third) * data.phaseOutRate;
  }
  return roundMoney(Math.max(0, credit) * multiplier);
}

function retirementCredit(income, data) {
  if (income >= data.end) return 0;
  if (income <= data.start) return data.max;
  return roundMoney(Math.max(0, data.max - (income - data.start) * data.rate));
}

function socialCreditMultiplier(data, older, socialSecurity) {
  var fullRate = data.bands[0].rate + data.socialRate;
  if (!socialSecurity) return (fullRate - data.socialRate) / fullRate;
  if (older) return (fullRate + data.aowSocialRate - data.socialRate) / fullRate;
  return 1;
}

function calculate(options) {
  var input = options || {};
  var year = Number(input.year);
  var data = TAX_YEARS[year];
  var enteredSalary = parseAmount(input.income);
  var monthly = input.period === "month";

  if (!data) return { valid: false, error: "Choose tax year 2025 or 2026." };
  if (!(enteredSalary > 0)) return { valid: false, error: "Enter a gross salary greater than zero." };

  var baseGross = enteredSalary * (monthly ? 12 : 1);
  var gross = baseGross * (input.addHoliday ? 1.08 : 1);
  var taxable = gross;
  var taxFree = 0;

  if (input.ruling === true) {
    var rulingType = ["normal", "young", "research"].indexOf(input.rulingType) >= 0
      ? input.rulingType : "normal";
    var eligibleSalary = Math.min(gross, data.rulingCap);
    var salaryAboveCap = Math.max(0, gross - data.rulingCap);
    var rulingTaxable = Math.max(
      eligibleSalary * 0.7 + salaryAboveCap,
      data.rulingThreshold[rulingType]
    );
    taxable = Math.min(gross, rulingTaxable);
    taxFree = Math.max(0, gross - taxable);
  }

  var older = input.older === true;
  var socialSecurity = input.socialSecurity !== false;
  var payrollTax = progressiveTax(taxable, data.bands);
  var socialRate = older ? data.aowSocialRate : data.socialRate;
  var socialTax = socialSecurity
    ? roundMoney(Math.min(taxable, data.socialCap) * socialRate)
    : 0;
  var taxBeforeCredits = roundMoney(payrollTax + socialTax);
  var creditMultiplier = socialCreditMultiplier(data, older, socialSecurity);
  var general = generalCredit(taxable, data.generalCredit, creditMultiplier);
  var labor = laborCredit(taxable, data.laborCredit, creditMultiplier);
  var elder = older ? retirementCredit(taxable, data.elderCredit) : 0;
  var credits = roundMoney(general + labor + elder);
  var taxAfterCredits = roundMoney(Math.max(0, taxBeforeCredits - credits));
  var net = roundMoney(Math.max(0, gross - taxAfterCredits));

  return {
    valid: true,
    year: year,
    enteredSalary: roundMoney(enteredSalary),
    baseGrossYear: roundMoney(baseGross),
    grossYear: roundMoney(gross),
    taxableYear: roundMoney(taxable),
    taxFreeYear: roundMoney(taxFree),
    payrollTax: payrollTax,
    socialTax: socialTax,
    generalCredit: general,
    laborCredit: labor,
    elderCredit: elder,
    totalCredits: credits,
    taxBeforeCredits: taxBeforeCredits,
    taxAfterCredits: taxAfterCredits,
    netYear: net,
    netMonth: roundMoney(net / 12),
    effectiveRate: gross > 0 ? taxAfterCredits / gross : 0,
    marginalRate: (taxable <= data.socialCap && socialSecurity ? socialRate : 0)
      + (taxable <= data.bands[0].max ? data.bands[0].rate
        : taxable <= data.bands[1].max ? data.bands[1].rate : data.bands[2].rate)
  };
}
