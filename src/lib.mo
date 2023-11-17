module {
	public type Asset = { symbol : Text; class_ : AssetClass };

	public type AssetClass = { #Cryptocurrency; #FiatCurrency };

	/// The parameters for the `get_exchange_rate` API call.
	public type GetExchangeRateRequest = {
		base_asset : Asset;
		quote_asset : Asset;
		/// An optional timestamp to get the rate for a specific time period.
		timestamp : ?Nat64;
	};

	public type GetExchangeRateResult = {
		#Ok : ExchangeRate;
		#Err : ExchangeRateError;
	};

	public type ExchangeRate = {
		base_asset : Asset;
		quote_asset : Asset;
		timestamp : Nat64;
		rate : Nat64;
		metadata : ExchangeRateMetadata;
	};

	public type ExchangeRateError = {
		//// Returned when the canister receives a call from the anonymous principal.
		#AnonymousPrincipalNotAllowed;
		//// Returned when the canister is in process of retrieving a rate from an exchange.
		#Pending;
		/// Returned when the base asset rates are not found from the exchanges HTTP outcalls.
		#CryptoBaseAssetNotFound;
		/// Returned when the quote asset rates are not found from the exchanges HTTP outcalls.
		#CryptoQuoteAssetNotFound;
		/// Returned when neither forex asset is found.
		#ForexAssetsNotFound;
		/// Returned when a rate for the provided forex asset could not be found at the provided timestamp.
		#ForexInvalidTimestamp;
		/// Returned when the forex base asset is found.
		#ForexBaseAssetNotFound;
		/// Returned when the forex quote asset is found.
		#ForexQuoteAssetNotFound;
		/// Returned when the stablecoin rates are not found from the exchanges HTTP outcalls needed for computing a crypto/fiat pair.
		#StablecoinRateNotFound;
		/// Returned when there are not enough stablecoin rates to determine the forex/USDT rate.
		#StablecoinRateTooFewRates;
		/// Returned when the stablecoin rate is zero.
		#StablecoinRateZeroRate;
		/// Returned when the caller is not the CMC and there are too many active requests.
		#RateLimited;
		/// Returned when the caller does not send enough cycles to make a request.
		#NotEnoughCycles;
		/// Returned when the canister fails to accept enough cycles.
		#FailedToAcceptCycles;
		//// Returned if too many collected rates deviate substantially.
		#InconsistentRatesReceived;
		/// Until candid bug is fixed, new errors after launch will be placed here.
		#Other : {
			/// The identifier for the error that occurred.
			code : Nat32;
			/// A description of the error that occurred.
			description : Text;
		};
	};

	public type ExchangeRateMetadata = {
		decimals : Nat32;
		forex_timestamp : ?Nat64;
		quote_asset_num_received_rates : Nat64;
		base_asset_num_received_rates : Nat64;
		base_asset_num_queried_sources : Nat64;
		standard_deviation : Nat64;
		quote_asset_num_queried_sources : Nat64;
	};

	public type Service = actor {
		get_exchange_rate : shared GetExchangeRateRequest -> async GetExchangeRateResult;
	};

	public let xrc = actor("uf6dk-hyaaa-aaaaq-qaaaq-cai") : Service;
};