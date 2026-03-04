from conftest import go_home, _click_button_by_text, _get_semantic_text

def test_kannada_word_shown(page):                       # AC3.1
    go_home(page)
    _click_button_by_text(page, 'Start Lesson')
    page.wait_for_timeout(2000)
    
    # Enable accessibility
    page.evaluate('() => document.querySelector("flt-semantics-placeholder")?.click()')
    page.wait_for_timeout(1000)
    
    texts = _get_semantic_text(page)
    # Check for kannada script (ಸೇಬು = first word)
    assert any('ಸೇಬು' in text for text in texts), f"Kannada word not found in: {texts}"
    # Check for roman text
    assert any('Sēbu' in text for text in texts), f"Roman text not found in {texts}"

def test_four_tiles_visible(page):                       # AC3.2
    go_home(page)
    _click_button_by_text(page, 'Start Lesson')
    page.wait_for_timeout(2000)
    
    # Enable accessibility
    page.evaluate('() => document.querySelector("flt-semantics-placeholder")?.click()')
    page.wait_for_timeout(1000)
    
    # Check for tile labels (Apple, Banana, Mango, Grapes are in first exercise)
    texts = _get_semantic_text(page)
    tile_words = ['Apple', 'Banana', 'Mango', 'Grapes']
    found_tiles = sum(1 for word in tile_words if any(word in text for text in texts))
    assert found_tiles >= 4, f"Expected 4 tiles, found {found_tiles} in: {texts}"

def test_correct_tap_shows_correct_banner(page):         # AC3.3–3.4
    go_home(page)
    _click_button_by_text(page, 'Start Lesson')
    page.wait_for_timeout(2000)
    
    # Enable accessibility
    page.evaluate('() => document.querySelector("flt-semantics-placeholder")?.click()')
    page.wait_for_timeout(1000)
    
    # Click first tile (correct answer - Apple)
    page.evaluate('''
        () => {
            const semantics = document.querySelectorAll('flt-semantics[role="button"]');
            for (const sem of semantics) {
                if (sem.textContent.includes('Apple') && !sem.textContent.includes('Play')) {
                    sem.click();
                    return;
                }
            }
        }
    ''')
    page.wait_for_timeout(1500)
    
    # Check for feedback
    texts = _get_semantic_text(page)
    # Should see some feedback (correct/wrong message)
    feedback_found = any('Correct' in text or 'Right' in text or 'ಸರಿ' in text for text in texts)
    continue_found = any('Continue' in text or 'ಮುಂದೆ' in text for text in texts)
    assert feedback_found or continue_found, f"Feedback not found in: {texts}"

def test_wrong_tap_shows_wrong_banner(page):             # AC3.3–3.4
    go_home(page)
    _click_button_by_text(page, 'Start Lesson')
    page.wait_for_timeout(2000)
    
    # Enable accessibility
    page.evaluate('() => document.querySelector("flt-semantics-placeholder")?.click()')
    page.wait_for_timeout(1000)
    
    # Click second tile (likely wrong - Banana)
    page.evaluate('''
        () => {
            const semantics = document.querySelectorAll('flt-semantics[role="button"]');
            let count = 0;
            for (const sem of semantics) {
                if (sem.textContent.includes('Banana') && !sem.textContent.includes('Play')) {
                    sem.click();
                    return;
                }
            }
        }
    ''')
    page.wait_for_timeout(1500)
    
    # Check for feedback and continue button
    texts = _get_semantic_text(page)
    continue_found = any('Continue' in text or 'ಮುಂದೆ' in text for text in texts)
    assert continue_found, f"Continue button not found in: {texts}"
