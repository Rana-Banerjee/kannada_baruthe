from conftest import go_home, _click_button_by_text, _get_semantic_text

def test_app_name_visible(page):                         # AC1.1
    go_home(page)
    texts = _get_semantic_text(page)
    # Check that app name is present in semantics
    assert any('Kannada Baruthe' in text for text in texts), f"App name not found in: {texts}"

def test_start_button_present(page):                     # AC1.1
    go_home(page)
    texts = _get_semantic_text(page)
    assert any('Start Lesson' in text for text in texts), f"Start button not found in: {texts}"

def test_no_resume_on_fresh_start(page):                 # AC1.2
    go_home(page)
    texts = _get_semantic_text(page)
    # Resume should not appear on fresh start
    assert not any('Resume' in text for text in texts), f"Resume found unexpectedly in: {texts}"

def test_resume_shown_after_checkpoint(page):            # AC1.2
    go_home(page)
    # Start lesson
    _click_button_by_text(page, 'Start Lesson')
    page.wait_for_timeout(2000)
    
    # Enable accessibility on lesson page
    page.evaluate('() => document.querySelector("flt-semantics-placeholder")?.click()')
    page.wait_for_timeout(1000)
    
    # Get first tile (just complete one exercise - click Apple)
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
    
    # Click Continue button if appears
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
    page.wait_for_timeout(1000)
    
    # Go back to home
    page.go_back()
    page.wait_for_timeout(2000)
    
    # Enable accessibility
    page.evaluate('() => document.querySelector("flt-semantics-placeholder")?.click()')
    page.wait_for_timeout(1000)
    
    texts = _get_semantic_text(page)
    # Resume/Restart should now appear
    has_resume = any('Resume' in text for text in texts)
    has_restart = any('Restart' in text for text in texts)
    assert has_resume or has_restart, f"Resume/Restart not found in: {texts}"
