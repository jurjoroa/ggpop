#' Search and list Font Awesome icons
#'
#' Retrieves Font Awesome icon names, optionally filtered by a search query or
#' category. Results can be returned as a plain character vector or as a tibble
#' with category classification.
#'
#' @param query Character string. Filter icons whose names contain \code{query}.
#'   Set to \code{NULL} (default) to return all icons. If \code{regex = TRUE},
#'   \code{query} is treated as a Perl-compatible regular expression.
#' @param category Character vector. One or more category names to filter by.
#'   Run \code{fa_categories()} to see valid options. Setting \code{category}
#'   implies \code{classify = TRUE}.
#' @param regex Logical. When \code{TRUE}, \code{query} is interpreted as a
#'   Perl-compatible regular expression. Default \code{FALSE} (fixed-string
#'   match).
#' @param classify Logical. When \code{TRUE} (default), each icon is classified
#'   into categories using \code{class_map} and a \code{primary_class} column is
#'   included in the returned tibble. Ignored when \code{as_vector = TRUE} and
#'   \code{category = NULL}.
#' @param include_unclassified Logical. When \code{FALSE}, icons that do not
#'   match any category pattern are dropped. Default \code{TRUE}.
#' @param class_map A named list mapping category names to regex patterns.
#'   Defaults to the internal \code{.fa_default_class_map()}.
#' @param primary_only Logical. When \code{TRUE} (default), the tibble contains
#'   only the \code{primary_class} column and omits \code{all_classes}.
#' @param as_vector Logical. When \code{TRUE}, return a plain sorted character
#'   vector of icon names instead of a tibble. If \code{category = NULL},
#'   classification is skipped entirely. Default \code{FALSE}.
#'
#' @return When \code{as_vector = TRUE}, a sorted character vector of icon names.
#'   Otherwise a \code{\link[tibble:tibble]{tibble}} with columns:
#'   \describe{
#'     \item{icon}{Icon name (character).}
#'     \item{primary_class}{Primary category the icon belongs to, or \code{NA}
#'       when unclassified (character).}
#'     \item{all_classes}{All matching categories (list-column of character
#'       vectors). Only present when \code{primary_only = FALSE}.}
#'   }
#'
#' @examples
#' \donttest{
#' # All icons as a classified tibble
#' fa_icons()
#'
#' # Quick lookup -- plain sorted vector
#' head(fa_icons(as_vector = TRUE), 10)
#'
#' # Search for icons whose name contains "heart"
#' fa_icons(query = "heart")
#'
#' # Filter by category
#' fa_icons(category = "animals")
#'
#' # Regex search -- all icons starting with "arrow"
#' fa_icons(query = "^arrow", regex = TRUE)
#' }
#'
#' @importFrom tibble tibble
#' @export
fa_icons <- function(query                = NULL,
                     category             = NULL,
                     regex                = FALSE,
                     classify             = TRUE,
                     include_unclassified = TRUE,
                     class_map            = NULL,
                     primary_only         = TRUE,
                     as_vector            = FALSE) {

  # ── Type / length checks ─────────────────────────────────────────────────────
  if (!is.null(query) && (!is.character(query) || length(query) != 1L))
    cli::cli_abort(
      "{.arg query} must be a single character string, not {.obj_type_friendly query}."
    )

  if (!is.null(category) && !is.character(category))
    cli::cli_abort(
      "{.arg category} must be a character vector, not {.obj_type_friendly category}."
    )

  if (!is.logical(regex) || length(regex) != 1L || is.na(regex))
    cli::cli_abort("{.arg regex} must be {.val TRUE} or {.val FALSE}.")

  if (!is.logical(classify) || length(classify) != 1L || is.na(classify))
    cli::cli_abort("{.arg classify} must be {.val TRUE} or {.val FALSE}.")

  if (!is.logical(include_unclassified) || length(include_unclassified) != 1L || is.na(include_unclassified))
    cli::cli_abort("{.arg include_unclassified} must be {.val TRUE} or {.val FALSE}.")

  if (!is.logical(primary_only) || length(primary_only) != 1L || is.na(primary_only))
    cli::cli_abort("{.arg primary_only} must be {.val TRUE} or {.val FALSE}.")

  if (!is.logical(as_vector) || length(as_vector) != 1L || is.na(as_vector))
    cli::cli_abort("{.arg as_vector} must be {.val TRUE} or {.val FALSE}.")

  if (!is.null(class_map) &&
      (!is.list(class_map) || is.null(names(class_map)) || any(!nzchar(names(class_map)))))
    cli::cli_abort(
      c(
        "{.arg class_map} must be a fully named list.",
        "i" = "Each element must have a non-empty name (the category label)."
      )
    )

  # ── Contradictory argument combinations ──────────────────────────────────────
  if (!classify && !include_unclassified)
    cli::cli_warn(
      c(
        "{.arg include_unclassified = FALSE} has no effect when {.arg classify = FALSE}.",
        "i" = "Set {.arg classify = TRUE} to enable filtering of unclassified icons."
      )
    )

  if (as_vector && !primary_only)
    cli::cli_warn(
      "{.arg primary_only = FALSE} is ignored when {.arg as_vector = TRUE}."
    )

  # ── Build class map and validate categories ──────────────────────────────────
  if (is.null(class_map)) class_map <- .fa_default_class_map()

  if (!is.null(category)) {
    bad <- setdiff(category, names(class_map))
    if (length(bad))
      cli::cli_abort(c(
        "Unknown {.arg category}: {.val {bad}}",
        "i" = "Run {.fn fa_categories} to see valid options."
      ))
    classify <- TRUE
  }

  # ── Retrieve and filter icons ────────────────────────────────────────────────
  icons <- .get_fa_icons()

  if (!is.null(query) && nzchar(query)) {
    icons <- if (regex) {
      tryCatch(
        icons[grepl(query, icons, perl = TRUE)],
        warning = function(w) cli::cli_abort(
          c(
            "{.arg query} is not a valid regular expression.",
            "x" = conditionMessage(w)
          )
        ),
        error = function(e) cli::cli_abort(
          c(
            "{.arg query} is not a valid regular expression.",
            "x" = conditionMessage(e)
          )
        )
      )
    } else {
      icons[grepl(query, icons, fixed = TRUE)]
    }
  }

  # shortcut: if just a vector is needed, skip classification entirely
  if (as_vector && is.null(category)) {
    if (length(icons) == 0L)
      cli::cli_warn(
        "No icons matched {.arg query = \"{query}\"}. Returning an empty vector."
      )
    return(sort(icons))
  }

  if (!classify) {
    if (length(icons) == 0L)
      cli::cli_warn(
        "No icons matched {.arg query = \"{query}\"}. Returning an empty vector."
      )
    return(sort(icons))
  }

  # ── Classify ─────────────────────────────────────────────────────────────────
  all_classes <- lapply(icons, function(ic) {
    names(class_map)[vapply(class_map, function(pat) grepl(pat, ic, perl = TRUE), logical(1))]
  })

  primary_class <- vapply(all_classes, function(x) {
    if (length(x)) x[[1L]] else NA_character_
  }, character(1))

  out <- tibble::tibble(
    icon          = icons,
    primary_class = primary_class,
    all_classes   = all_classes
  )

  if (primary_only) out$all_classes <- NULL

  if (!is.null(category)) {
    in_category <- vapply(all_classes, function(x) any(x %in% category), logical(1))
    out <- out[in_category, , drop = FALSE]
  }

  if (!include_unclassified) {
    out <- out[!is.na(out$primary_class), , drop = FALSE]
  }

  # ── Warn on empty results ────────────────────────────────────────────────────
  if (nrow(out) == 0L) {
    if (!is.null(query) && !is.null(category))
      cli::cli_warn(
        "No icons matched {.arg query = \"{query}\"} in categor{?y/ies} {.val {category}}."
      )
    else if (!is.null(category))
      cli::cli_warn(
        "No icons found in categor{?y/ies} {.val {category}}."
      )
    else
      cli::cli_warn(
        "No icons matched {.arg query = \"{query}\"}."
      )
  }

  # return plain vector instead of tibble
  if (as_vector) return(out$icon)

  out
}

#' List available Font Awesome icon categories
#'
#' Returns the names of all built-in category groups used by \code{\link{fa_icons}}.
#'
#' @param class_map A named list mapping category names to regex patterns.
#'   Defaults to the internal \code{.fa_default_class_map()}.
#'
#' @return A sorted character vector of category names.
#'
#' @examples
#' fa_categories()
#'
#' @noRd
fa_categories <- function(class_map = NULL) {
  if (is.null(class_map)) class_map <- .fa_default_class_map()
  sort(names(class_map))
}

# ── Internal helpers ──────────────────────────────────────────────────────────

# Fetches Font Awesome icon names from fontawesome once per session and caches
# the result in .ggpop_env. Subsequent calls return the cached vector instantly.
#' @keywords internal
#' @noRd
.get_fa_icons <- function() {
  if (is.null(.ggpop_env$fa_icon_names)) {
    .ggpop_env$fa_icon_names <- fontawesome::fa_metadata()$icon_names
  }
  .ggpop_env$fa_icon_names
}

# ── Internal class map ────────────────────────────────────────────────────────

.fa_default_class_map <- function() {
  list(
    
    # ── Brands ───────────────────────────────────────────────────────────────
    brands_social =
      "facebook|instagram|linkedin|twitter|x-twitter|youtube|tiktok|snapchat|pinterest|reddit|tumblr|whatsapp|telegram|discord|slack|skype|twitch|vimeo|spotify|soundcloud|medium|quora|wechat|weibo|yahoo",
    
    brands_dev_cloud =
      "github|gitlab|bitbucket|npm|node-js|\\bjs\\b|python|java|php|html5|css3|react|vuejs|angular|docker|linux|ubuntu|debian|fedora|centos|windows|aws|digital-ocean|cloudflare|google|microsoft",
    
    brands_commerce =
      "amazon|ebay|etsy|shopify|stripe|paypal|apple-pay|google-pay|cc-|bitcoin|btc|ethereum|uber|airbnb",
    
    # catch-all for brand/logo icons not covered by the three groups above
    brands_misc =
      "^(42-group|500px|accusoft|adn|adversal|affiliatetheme|algolia|alipay|amilia|android|angellist|angrycreative|app-store|apper|apple|artstation|asymmetrik|atlassian|audible|autoprefixer|avianex|aviato|bandcamp|battle-net|behance|bilibili|bimobject|bity|black-tie|blackberry|bluesky|bluetooth|bootstrap|brave|buffer|buromobelexperte|buy-n-large|buysellads|cable-car|centercode|chrome|chromecast|cloudscale|cloudsmith|cloudversify|cmplid|codepen|codiepie|confluence|connectdevelop|contao|cotton-bureau|cpanel|creative-commons|critical-role|cuttlefish|d-and-d|dailymotion|dashcube|deezer|delicious|deploydog|deskpro|dev|deviantart|dhl|diaspora|digg|discourse|dochub|draft2digital|dribbble|dropbox|drupal|dyalog|earlybirds|edge|elementor|ello|ember|empire|envira|erlang|evernote|expeditedssl|fantasy-flight-games|fedex|figma|firefox|first-order|firstdraft|flickr|flipboard|fly|font-awesome|fonticons|fort-awesome|forumbee|foursquare|free-code-camp|freebsd|fulcrum|galactic-republic|galactic-senate|get-pocket|gg|gitkraken|gitter|glide|gofore|golang|goodreads|gratipay|grav|gripfire|grunt|guilded|gulp|hacker-news|hackerrank|hashnode|hire-a-helper|hips|hive|hooli|hornbill|hotjar|houzz|hubspot|ideal|imdb|instalod|intercom|internet-explorer|invision|ioxhost|itch-io|itunes|jenkins|jira|joget|joomla|jsfiddle|jxl|kaggle|keybase|keycdn|kickstarter|korvue|laravel|lastfm|leanpub|letterboxd|line|linode|lyft|magento|mailchimp|mandalorian|mastodon|maxcdn|mdb|medapps|medrt|meetup|megaport|mendeley|meta|microblog|mintbit|mix|mixcloud|mixer|mizuni|modx|monero|napster|neos|nimblr|node|ns8|nutritionix|octopus-deploy|odnoklassniki|odysee|old-republic|opencart|openid|opensuse|opera|optin-monster|orcid|osi|padlet|page4|pagelines|palfed|patreon|perbyte|periscope|phabricator|phoenix-framework|phoenix-squadron|pied-piper|pixiv|pix|playstation|product-hunt|pushed|qq|quinscape|r-project|raspberry-pi|ravelry|readme|rebel|red-river|redhat|renren|replyd|researchgate|resolving|rev|rocketchat|rockrms|rust|safari|salesforce|sass|schlix|screenpal|scribd|searchengin|sellcast|sellsy|servicestack|shirtsinbulk|shoelace|shopware|simplybuilt|sistrix|sitrox|sketch|skyatlas|slideshare|sourcetree|space-awesome|speakap|speaker-deck|squarespace|stack-exchange|stack-overflow|stackpath|staylinked|steam|sticker-mule|strava|stroopwafel|stubber|studiovinari|stumbleupon|superpowers|supple|suse|swift|symfony|teamspeak|the-red-yeti|themeco|themeisle|think-peaks|threads|trade-federation|trello|typo3|uikit|umbraco|uncharted|uniregistry|unity|unsplash|untappd|ups|upwork|usps|ussunnah|vaadin|viacoin|viadeo|viber|vine|vk|vnv|watchman-monitoring|waze|web-awesome|webflow|weebly|weixin|whmcs|wikipedia-w|wirsindhandwerk|wix|wizards-of-the-coast|wodu|wolf-pack-battalion|wordpress|wpbeginner|wpexplorer|wpforms|wpressr|xbox|xing|y-combinator|yammer|yandex|yarn|yelp|yoast|zhihu|blogger)(-|$)",
    
    # ── People & identity ─────────────────────────────────────────────────────
    people_users    = "^(user|users|person|people)(-|$)",
    faces_emotions  = "^face-",
    hands_arms      = "^hands?(-|$)",
    accessibility   = "^(wheelchair|universal-access|accessible-icon|person-walking-with-cane|ear-|eye-low-vision|audio-description)(-|$)",
    
    gender_identity =
      "^(mars|venus|mercury|transgender|genderless|neuter)(-|$)",
    
    people_social =
      "^(baby|child|children|chalkboard|graduation-cap|handshake|hot-tub-person|paw|peace|democrat|republican|braille|language|newspaper|blog|blogger|piggy-bank|wallet|briefcase|business-time|sitemap|headset|helmet-un|weight)(-|$)",
    
    # ── UI ────────────────────────────────────────────────────────────────────
    ui_navigation   = "^(bars|ellipsis|chevron|caret|angle|xmark|check|plus|minus|toggle|sliders?|grip|list|sort|filter|search|magnifying-glass|expand|compress|maximize|minimize)(-|$)",
    ui_actions      = "^(share|download|upload|print|copy|paste|save|floppy-disk|trash|trash-can|edit|pen|pen-to-square|pencil|reply|reply-all|retweet|rotate|arrows-rotate|sync)(-|$)",
    text_formatting = "^(bold|italic|underline|strikethrough|superscript|subscript|paragraph|align|indent|outdent|quote|text)(-|$)",
    
    # icons that don't start with "arrow/arrows" but are directional
    arrows_extra =
      "^(angles|down-long|left-long|left-right|right-long|up-long|up-down|turn-down|turn-up|down-left-and-up-right-to-center|up-right-and-down-left-from-center|up-right-from-square|right-from-bracket|right-left|right-to-bracket|xmarks-lines|eject|group-arrows-rotate|diamond-turn-right)(-|$)",
    
    # miscellaneous UI controls and indicators
    ui_controls =
      "^(asterisk|ban|barcode|bell|border|clone|closed-captioning|coins|copyright|crop|crosshairs|delete-left|diamond|divide|equals|eraser|exclamation|eye|fax|fill|font|gear|gears|greater-than|heading|highlighter|i-cursor|icons|image|images|infinity|info|less-than|less|lines-leaning|link|marker|not-equal|notdef|pager|panorama|percent|power-off|qrcode|question|registered|repeat|ribbon|scissors|section|shuffle|signature|slash|spell-check|spinner|splotch|spray-can|stamp|stapler|table|tachograph-digital|tags|thumbs|trademark|bezier-curve|draw-polygon|layer-group|object-group|object-ungroup|shapes|vector-square|wave-square)(-|$)",
    
    # ── Arrows & navigation ───────────────────────────────────────────────────
    arrows_directional  = "^arrows?(-|$)",
    location_navigation = "^(location|map|compass|route|road|street-view|globe|earth)(-|$)",
    
    # ── Files & office ────────────────────────────────────────────────────────
    files_folders = "^(file|folder)(-|$)",
    office_docs   = "^(clipboard|paperclip|envelope|calendar|book|bookmark|note-sticky|address)(-|$)",
    charts_analytics = "^(chart|diagram|ranking-star|gauge|meter|timeline)(-|$)",
    
    # ── Communication & media ─────────────────────────────────────────────────
    communication   = "^(phone|mobile|comment|comments|message|messages|inbox|rss|signal)(-|$)",
    media_controls  = "^(play|pause|stop|forward|backward|record-vinyl|circle-play|circle-pause|circle-stop|volume|microphone|headphones)(-|$)",
    media_filetypes = "^file-(audio|video|image|pdf|word|excel|powerpoint)(-|$)",
    devices_hardware = "^(camera|video|tv|computer|desktop|laptop|tablet|mobile|keyboard|mouse|printer|wifi|ethernet|hard-drive|microchip|memory|server)(-|$)",
    
    tech_science =
      "^(atom|bots|code|database|display|flask|git|markdown|network-wired|nfc|robot|satellite|sd-card|sim-card|terminal|tty|usb|vr-cardboard)(-|$)",
    
    # ── Security ─────────────────────────────────────────────────────────────
    security_privacy = "^(lock|unlock|key|shield|fingerprint|user-lock|user-shield|mask|bug|biohazard)(-|$)",
    
    # ── Money & shopping ──────────────────────────────────────────────────────
    money_currency =
      "^(dollar|euro|pound|yen|ruble|rupee|won|naira|shekel|hryvnia|lira|franc|cent|bitcoin-sign|ethereum|baht|taka|peso|peseta|guarani|kip|lari|manat|tenge|cedi)(-|$)|(-sign)$",
    shopping_commerce = "^(cart|basket|bag|shop|store|cash-register|receipt|credit-card|money|sack)(-|$)",
    
    # ── Medical & emergency ───────────────────────────────────────────────────
    medical_health    = "^(kit-medical|hospital|stethoscope|syringe|pills|dna|virus|viruses|disease|heart|lungs|bandage|briefcase-medical|user-doctor|user-nurse)(-|$)",
    emergency_hazards = "^(triangle-exclamation|circle-exclamation|skull|skull-crossbones|radiation|fire|explosion|bolt|tornado|hurricane)(-|$)",
    
    medical_extra =
      "^(bacteria|bacterium|ban-smoking|bong|bone|brain|bugs|cannabis|capsules|crutch|dumbbell|drumstick-bite|ear-deaf|ear-listen|head-side|joint|microscope|mortar-pestle|notes-medical|poo|poop|prescription|pump-medical|smoking|staff-snake|tablets|teeth|thermometer|toilets-portable|tooth|vial|vials|x-ray)(-|$)",
    
    # ── Transport ─────────────────────────────────────────────────────────────
    transport_ground  = "^(car|truck|bus|taxi|motorcycle|bicycle|van-shuttle|tractor|train|subway)(-|$)",
    transport_air_sea = "^(plane|jet-fighter|helicopter|rocket|ship|sailboat|ferry)(-|$)",
    travel_places     = "^(hotel|passport|suitcase|campground)(-|$)",
    
    transport_extra =
      "^(caravan|shuttle-space|trailer|traffic-light|tower-broadcast|tower-cell|tower-observation)(-|$)",
    
    # ── Buildings & places ────────────────────────────────────────────────────
    buildings_places = "^(house|building|city|school|church|mosque|synagogue|gopuram|torii-gate|landmark|hospital)(-|$)",
    government_law   = "^(gavel|scale|building-columns|flag)(-|$)",
    
    buildings_extra =
      "^(archway|bath|bed|chair|couch|door|dumpster|elevator|faucet|igloo|mattress-pillow|monument|restroom|rug|sign-hanging|signs-post|stairs|tent|tents|vault|warehouse|window)(-|$)",
    
    # ── Religion ─────────────────────────────────────────────────────────────
    religion_symbols = "^(cross|ankh|om|star-of-david|hanukiah|dharmachakra|scroll-torah)(-|$)",
    
    religion_extra =
      "^(bahai|hamsa|jedi|kaaba|khanda|menorah|place-of-worship|sith|spaghetti-monster-flying|vihara|yin-yang)(-|$)",
    
    # ── Food & home ───────────────────────────────────────────────────────────
    food_drink = "^(apple-whole|burger|pizza|hotdog|bacon|cheese|bread|cake|ice-cream|lemon|pepper-hot|fish|shrimp|beer|martini-glass|wine)(-|$)",
    household  = "^(utensils|blender|soap|pump-soap|toilet|toilet-paper|sink|shower|broom|bucket)(-|$)",
    
    food_extra =
      "^(bowl|bottle-water|bottle-droplet|candy-cane|carrot|champagne-glasses|cookie|egg|glass-water|jar|kitchen-set|mug|plate-wheat|spoon|whiskey-glass|wheat-awn)(-|$)",
    
    # ── Nature & environment ──────────────────────────────────────────────────
    nature      = "^(leaf|seedling|recycle|tree|mountain|sun|moon|cloud|rainbow|snowflake|water|droplet|volcano|wind)(-|$)",
    weather     = "^(cloud|sun|snow|icicles|umbrella|temperature|hurricane|tornado)(-|$)",
    
    nature_extra =
      "^(bore-hole|clover|hill-avalanche|hill-rockslide|locust|meteor|mound|plant-wilt|smog|snowman|snowplow|worm)(-|$)",
    
    # ── Animals ───────────────────────────────────────────────────────────────
    animals = "^(cat|dog|fish|frog|hippo|horse|crow|dragon|spider|otter|kiwi-bird|cow|dove|mosquito)(-|$)",
    
    # ── Sports, games & hobbies ───────────────────────────────────────────────
    sports        = "^(football|baseball|basketball|bowling-ball|golf|futbol|volleyball|hockey-puck|table-tennis)(-|$)",
    games_hobbies = "^(dice|chess|gamepad|guitar|music|paintbrush|palette|pen-nib)(-|$)",
    
    # ── Tools, industry & energy ──────────────────────────────────────────────
    tools_construction = "^(wrench|screwdriver|hammer|toolbox|paint-roller|ruler|trowel|helmet-safety|road|bridge)(-|$)",
    industry_energy    = "^(industry|oil|gas-pump|charging-station|battery|plug|solar-panel|fire-burner)(-|$)",
    
    # ── Time & symbols ────────────────────────────────────────────────────────
    time          = "^(clock|hourglass|stopwatch|calendar)(-|$)",
    shapes_symbols = "^(circle|square|rectangle|triangle|star|gem|tag|hashtag|at)(-|$)",
    
    # ── Clothing & accessories ────────────────────────────────────────────────
    clothing =
      "^(glasses|handcuffs|hat|id-badge|id-card|mitten|ring|shirt|shoe-prints|socks|vest)(-|$)",
    
    # ── Entertainment & culture ───────────────────────────────────────────────
    entertainment =
      "^(award|bullhorn|bullseye|canadian-maple-leaf|certificate|clapperboard|compact-disc|crown|drum|dungeon|film|ghost|gift|gifts|gun|holly-berry|masks-theater|medal|photo-film|podcast|puzzle-piece|radio|scroll|sleigh|spa|swatchbook|ticket|trophy|voicemail|walkie-talkie|wand)(-|$)",
    
    # ── Packaging & logistics ─────────────────────────────────────────────────
    packaging =
      "^(anchor|bomb|box|boxes|burst|cube|cubes|dolly|envelopes-bulk|feather|jug-detergent|land-mine-on|life-ring|magnet|pallet|paper-plane|parachute-box|sheet-plastic|tarp|tape|thumbtack)(-|$)",
    
    # ── Miscellaneous objects ─────────────────────────────────────────────────
    objects_misc =
      "^(binoculars|brush|calculator|fan|gear|gears|lightbulb)(-|$)",
    
    # ── Single letters and digits ─────────────────────────────────────────────
    alphanumeric = "^[0-9a-z]$"
  )
}
