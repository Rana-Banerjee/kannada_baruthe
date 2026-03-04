from conftest import go_home, _click_button_by_text, _get_semantic_text

def test_progress_counter_visible(page):                 # AC2.2
    go_home(page)
    _click_button_by_text(page, 'Start Lesson')
    page.wait_for_timeout(2000)
    
    # Enable accessibility on lesson page
    page.evaluate('() => document.querySelector("flt-semantics-placeholder")?.click()')
    page.wait_for_timeout(1000)
    
    texts = _get_semantic_text(page)
    # Progress should show "1 / 10" or similar
    assert any('1 /' in text for text in texts), f"Progress not found in: {texts}"

def test_completion_after_last_exercise(page, lesson_data): # AC2.4
    go_home(page)
    _click_button_by_text(page, 'Start Lesson')
    
    # Complete all exercises
    num_exercises = len(lesson_data["exercises"])
    for i in range(num_exercises):
        page.wait_for_timeout(1500)
        
        # Enable accessibility if needed
        page.evaluate('() => { const p = document.querySelector("flt-semantics-placeholder"); if (p) p.click(); }')
        page.wait_for_timeout(500)
        
        # Find and click first tile (correct answer - Apple)
        # Click by finding button with Apple text (excluding Play audio)
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
        page.wait_for_timeout(1000)
        
        # Click Continue
        page.evaluate('''
            () => {
                const buttons = document.querySelectorAll('flt-semantics[role="button"]');
                for (const btn of buttons) {
                    if (btn.textContent.includes('Continue') || btn.textContent.includes('ಮುಂದೆ')) {
                        btn.click();
                    }
                }
            }
        ''')
        page.wait_for_timeout(500)
    
    # Check for completion
    page.wait_for_timeout(2000)
    # Enable accessibility again
    page.evaluate('() => document.querySelector("flt-semantics-placeholder")?.click()')
    page.wait_for_timeout(1000)
    
    texts = _get_semantic_text(page)
    # Should see completion message (Correct, Continue button disappears after last exercise)
    # or see score elements
    completion_found = any(
        'complete' in text.lower() or 
        'ಮುಗಿಯಿತು' in text or 
        'score' in text.lower() or 
        'ಅಂಕ' in text or
        '10 / 10' in text
        for text in texts
    )
    assert completion_found, f"Completion not found in: {texts}"
