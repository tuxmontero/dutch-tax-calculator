# Dutch Tax Calculator

An Omarchy Quickshell plugin for estimating Dutch salary tax and take-home pay. Click the **€** icon in the right side of the Omarchy bar to open the calculator.

## What it does

- Estimates Dutch Box 1 salary tax for tax years **2025 and 2026**.
- Accepts gross salary as an annual or monthly amount.
- Lets you include 8% holiday pay (vakantiegeld), Dutch social insurance, full-year AOW age, and an approved 30% ruling.
- Shows estimated net monthly and annual income, effective tax rate, tax credits, and annual tax due.
- Links to [TheTax.nl](https://thetax.nl) for a more detailed personal calculation.

## Calculation scope

Rates and credits are based on published Belastingdienst tables for Box 1, the general tax credit, and the labour tax credit for 2025 and 2026. The estimate is for individual salary income. It does not include pension deductions, Box 2/3 income, personal deductions, partner allocations, tax benefits, partial-year residency, or an AOW transition year. The 30% ruling option assumes that you already qualify and applies the selected category's minimum taxable-salary threshold and annual cap.

This calculator is for estimation only, not tax advice. Confirm important amounts with the Belastingdienst or a qualified Dutch tax adviser.

## Usage on Omarchy

The installed plugin lives at `~/.config/omarchy/plugins/jonathan.dutch-tax-calculator/`. The source files in this folder are a copy for review and development.

```bash
omarchy plugin enable jonathan.dutch-tax-calculator
omarchy plugin disable jonathan.dutch-tax-calculator
omarchy plugin validate ~/.config/omarchy/plugins/jonathan.dutch-tax-calculator
```

To validate the source copy from this directory:

```bash
omarchy plugin validate .
```

## Privacy

Calculations run locally. Salary inputs remain in shell memory while the calculator is open; the plugin does not store or transmit them. The external TheTax.nl page is opened only when you click its link.

## Source files

- `manifest.json` — Omarchy plugin metadata and entry points.
- `BarWidget.qml` — € bar button that opens the calculator.
- `Calculator.qml` — calculator panel UI.
- `TaxModel.js` — local tax and net-pay calculations.

## Official rate references

- [Belastingdienst: Box 1 tax rates](https://www.belastingdienst.nl/wps/wcm/connect/bldcontentnl/belastingdienst/prive/inkomstenbelasting/heffingskortingen_boxen_tarieven/boxen_en_tarieven/box_1/box_1)
- [General tax credit 2025](https://www.belastingdienst.nl/wps/wcm/connect/bldcontentnl/belastingdienst/prive/inkomstenbelasting/heffingskortingen_boxen_tarieven/heffingskortingen/algemene_heffingskorting/tabel-algemene-heffingskorting-2025)
- [General tax credit 2026](https://www.belastingdienst.nl/wps/wcm/connect/bldcontentnl/belastingdienst/prive/inkomstenbelasting/heffingskortingen_boxen_tarieven/heffingskortingen/algemene_heffingskorting/tabel-algemene-heffingskorting-2026)
- [Labour tax credit 2025](https://www.belastingdienst.nl/wps/wcm/connect/bldcontentnl/belastingdienst/prive/inkomstenbelasting/heffingskortingen_boxen_tarieven/heffingskortingen/arbeidskorting/tabel-arbeidskorting-2025)
- [Labour tax credit 2026](https://www.belastingdienst.nl/wps/wcm/connect/bldcontentnl/belastingdienst/prive/inkomstenbelasting/heffingskortingen_boxen_tarieven/heffingskortingen/arbeidskorting/tabel-arbeidskorting-2026)

## License

MIT. See [LICENSE](LICENSE).
