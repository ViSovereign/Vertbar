#!/usr/bin/env bash

# Config
CACHE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/weather.txt"
WTTR_API="wttr.in/?format=%c+%t"
OPENWEATHER_API="https://api.openweathermap.org/data/2.5/weather"
OPENWEATHER_API_KEY=""
CITY=""
COUNTRY_CODE="US"
UNITS="imperial"
MAX_RETRIES=2
TIMEOUT=5

# Ensure dependencies exist
if ! command -v curl &> /dev/null; then
    printf 'curlmissing'
    exit 1
fi

if ! command -v jq &> /dev/null; then
    printf 'jqmissing'
    exit 1
fi

get_weather_wttr() {
    curl -s -m "$TIMEOUT" "$WTTR_API"
}

get_weather_openweathermap() {
    local response
    response=$(curl -s -m "$TIMEOUT" \
        "$OPENWEATHER_API?q=$CITY,$COUNTRY_CODE&appid=$OPENWEATHER_API_KEY&units=$UNITS")
    # Validate API response
    if [[ -z "$response" ]] || ! echo "$response" | jq -e '.main.temp' >/dev/null 2>&1; then
        echo ""
        return 1
    fi

    local temperature icon_code weather_icon
    temperature=$(echo "$response" | jq -r '.main.temp | round')
    icon_code=$(echo "$response" | jq -r '.weather[0].icon')
    
    # Map OpenWeatherMap icon codes to emojis
    case "$icon_code" in
        "01d") weather_icon="☀️";;
        "01n") weather_icon="🌙";;
        "02d") weather_icon="⛅";;
        "02n") weather_icon="☁️";;
        "03"*) weather_icon="☁️";;
        "04"*) weather_icon="☁️";;
        "09"*) weather_icon="🌧️";;
        "10"*) weather_icon="🌦️";;
        "11"*) weather_icon="🌩️";;
        "13"*) weather_icon="❄️";;
        "50"*) weather_icon="🌫️";;
        *) weather_icon="";;
    esac

    case "$UNITS" in
        "metric") unit_symbol="C" ;;
        "imperial") unit_symbol="F" ;;
        *) unit_symbol="" ;;
    esac

    echo "$weather_icon $temperature°$unit_symbol"
}

# Main execution
mkdir -p "$(dirname "$CACHE_FILE")"

# Try wttr.in first
weather_data=$(get_weather_wttr)

# If wttr.in fails, try OpenWeatherMap
if [[ -z "$weather_data" ]] || [[ "$weather_data" == *"Unknown"* ]]; then
    weather_data=$(get_weather_openweathermap)
fi

# If still no data, use cache
if [[ -z "$weather_data" ]]; then
    if [[ -f "$CACHE_FILE" ]]; then
        cat "$CACHE_FILE"
        exit 0
    else
        printf "No weather data"
    fi
fi

# Process data
weather_icon=$(echo "$weather_data" | grep -oP '^\S+' | head -1)
temp_string=$(echo "$weather_data" | awk '{print $2}')
weather_temp="${temp_string#+*}"

# Generate output
output=$(printf '%s\n%s\n' \
    "$weather_icon" "$weather_temp")

# Cache and output
echo "$output" > "$CACHE_FILE"
#echo "$output"

# Remove F from string
new_string="${output//F/}"
echo "$new_string"