# Exchange Rate Canister interface

The exchange rate canister (XRC) is a canister running on the [uzr34 system subnet](https://dashboard.internetcomputer.org/subnet/uzr34-akd3s-xrdag-3ql62-ocgoh-ld2ao-tamcv-54e7j-krwgb-2gm4z-oqe) that provides exchange rates to requesting canisters. A request comprises a base asset, a quote asset, and an optional (UNIX epoch) timestamp. The base and quote asset can be any combination of cryptocurrency and fiat currency assets, for example, BTC/ICP, ICP/USD, or USD/EUR. The timestamp parameter makes it possible to request historic rates. If no timestamp is provided in the request, the rate for the current time is returned.

## Usage
The canister ID of the XRC is `uf6dk-hyaaa-aaaaq-qaaaq-cai`

For every request, 1B cycles need to be sent along, otherwise an `ExchangeRateError::NotEnoughCycles` error is returned. The actual cost of the call depends on two factors, the requested asset types and the state of the internal exchange rate cache, as follows:

- If the request can be served from the cache, the actual cost is 20M cycles.
- If both assets are fiat currencies, the cost is 20M cycles as well.
- If one of the assets is a fiat currency or the cryptocurrency USDT, the cost is 260M cycles.
- If both assets are cryptocurrencies, the cost is 500M cycles.

The remaining cycles are returned to the requesting canister. Note that at least 1M cycles are charged even in case of an error in order to mitigate the risk of a denial-of-service attack.

## Example
The following example shows how to request the exchange rate for the given base and quote cryptocurrency assets at the current time.

1. Add `xrc-types` dependency
```
mops add xrc-types
```

2. Import `XRC` and `ExperimentalCycles` in your Motoko code
```motoko
import XRC "mo:xrc-types";
import ExperimentalCycles "mo:base/ExperimentalCycles";
```

3. Define a function to request the exchange rate
```motoko
public func getExchangeRate(base : Text, quote : Text) : async Nat64 {
  let xrc = actor("uf6dk-hyaaa-aaaaq-qaaaq-cai") : XRC.Service;

  ExperimentalCycles.add(1_000_000_000);

  let res = await xrc.get_exchange_rate({
    base_asset = {
      class_ = #Cryptocurrency;
      symbol = base;
    };
    quote_asset = {
      class_ = #Cryptocurrency;
      symbol = quote;
    };
    timestamp = null;
  });

  switch(res) {
    case(#Ok(exchangeRate)) {
      exchangeRate.rate; // see also exchangeRate.metadata.decimals
    };
    case(#Err(err)) {
      throw Error.reject(debug_show(err));
    };
  };
};
```

4. Request the exchange rate
```motoko
let exchangeRate = await getExchangeRate("ICP", "USDT");
```

## Links
- [Docs](https://mops.one/xrc-types/docs)
- [Wiki](https://wiki.internetcomputer.org/wiki/Exchange_rate_canister)
- [Dashboard](https://dashboard.internetcomputer.org/canister/uf6dk-hyaaa-aaaaq-qaaaq-cai)
- [Candid](https://github.com/dfinity/exchange-rate-canister/blob/main/src/xrc/xrc.did)