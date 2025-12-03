// fuzzySearch.js - Fuzzy matching utility for app launcher

/**
 * Performs fuzzy matching between text and pattern
 * @param {string} text - The text to search in
 * @param {string} pattern - The pattern to search for
 * @returns {Object} - Object with match (boolean) and score (number) properties
 */
function fuzzyMatch(text, pattern) {
    if (!pattern) return { match: true, score: 0 }
    
    text = text.toLowerCase()
    pattern = pattern.toLowerCase()
    
    let textIndex = 0
    let patternIndex = 0
    let score = 0
    let consecutiveMatches = 0
    
    while (textIndex < text.length && patternIndex < pattern.length) {
        if (text[textIndex] === pattern[patternIndex]) {
            patternIndex++
            consecutiveMatches++
            // Bonus for consecutive matches
            score += consecutiveMatches * 10
        } else {
            consecutiveMatches = 0
            score -= 1
        }
        textIndex++
    }
    
    // Check if all pattern characters were matched
    let match = patternIndex === pattern.length
    
    if (match) {
        // Bonus for exact match at start
        if (text.startsWith(pattern)) {
            score += 100
        }
        // Bonus for word boundary matches
        let words = text.split(/\s+/)
        for (let word of words) {
            if (word.startsWith(pattern)) {
                score += 50
                break
            }
        }
    }
    
    return { match: match, score: score }
}

/**
 * Filters and sorts applications based on fuzzy search
 * @param {Array} apps - Array of application objects
 * @param {string} searchText - The search query
 * @returns {Array} - Sorted array of {app, score} objects
 */
function filterAndSortApps(apps, searchText) {
    let results = []
    
    for (let app of apps) {
        let result = fuzzyMatch(app.name, searchText)
        if (result.match) {
            results.push({
                app: app,
                score: result.score
            })
        }
    }
    
    // Sort by score (highest first), then by name
    results.sort((a, b) => {
        if (b.score !== a.score) {
            return b.score - a.score
        }
        return a.app.name.localeCompare(b.app.name)
    })
    
    return results
}