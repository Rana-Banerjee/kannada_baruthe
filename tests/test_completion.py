from conftest import go_home, _get_semantic_text

def _complete_lesson(page, lesson_data):
    """Complete all exercises in the lesson"""
    # Click Start Lesson
    page.evaluate('''
        () => {
            const buttons = document.querySelectorAll('flt-semantics[role="button"]');
            for (const btn of buttons) {
                if (btn.textContent.includes('Start Lesson')) btn.click();
            }
        }
    ''')
    
    num_exercises = len(lesson_data["exercises"])
    # We'll click Apple tile each time (first tile = correct in lesson_01)
    for i in range(num_exercises):
        page.wait_for_timeout(1500)
        
        # Enable accessibility if needed
        page.evaluate('() => { const p = document.querySelector("flt-semantics-placeholder"); if (p) p.click(); }')
        page.wait_for_timeout(500)
        
        # Click tile by finding button with text (Apple is correct each time in lesson_01)
        page.evaluate('''
            () => {
                const semantics = document.querySelectorAll('flt-semantics[role="button"]');
                for (const sem of semantics) {
                    // First tile is always correct (Apple) in lesson_01
                    if (sem.textContent.includes('Apple') && !sem.textContent.includes('Play audio')) {
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

def test_completion_elements(page, lesson_data):         # AC5.1
    go_home(page)
    _complete_lesson(page, lesson_data)
    page.wait_for_timeout(2000)
    
    # Enable accessibility
    page.evaluate('() => document.querySelector("flt-semantics-placeholder")?.click()')
    page.wait_for_timeout(1000)
    
    texts = _get_semantic_text(page)
    # Should see completion message
    complete_found = any(
        'complete' in text.lower() or 
        'ಮುಗಿಯಿತು' in text or 
        'score' in text.lower() or 
        'ಅಂಕ' in text
        for text in texts
    )
    assert complete_found, f"Completion elements not found in: {texts}"

def test_back_to_home_clears_checkpoint(page, lesson_data): # AC5.2
    go_home(page)
    _complete_lesson(page, lesson_data)
    page.wait_for_timeout(2000)
    
    # Enable accessibility and click home button
    page.evaluate('() => document.querySelector("flt-semantics-placeholder")?.click()')
    page.wait_for_timeout(1000)
    
    # Click home button
    page.evaluate('''
        () => {
            const buttons = document.querySelectorAll('flt-semantics[role="button"]');
            for (const btn of buttons) {
                if (btn.textContent.includes('Home') || btn.textContent.includes('ಮುಖ')) {
                    btn.click();
                }
            }
        }
    ''')
    page.wait_for_timeout(2000)
    
    # Go to home again and check no resume
    page.goto('http://localhost:8080')
    page.wait_for_timeout(3000)
    page.evaluate('() => document.querySelector("flt-semantics-placeholder")?.click()')
    page.wait_for_timeout(1000)
    
    texts = _get_semantic_text(page)
    # Resume should NOT appear
    assert not any('Resume' in text for text in texts), f"Resume found unexpectedly in: {texts}"
