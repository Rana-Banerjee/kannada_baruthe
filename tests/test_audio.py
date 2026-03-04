from conftest import go_home, _get_semantic_text

def test_audio_button_present_and_clickable(page):       # AC4.1
    go_home(page)
    # Click Start Lesson
    page.evaluate('''
        () => {
            const buttons = document.querySelectorAll('flt-semantics[role="button"]');
            for (const btn of buttons) {
                if (btn.textContent.includes('Start Lesson')) btn.click();
            }
        }
    ''')
    page.wait_for_timeout(2000)
    
    # Enable accessibility
    page.evaluate('() => document.querySelector("flt-semantics-placeholder")?.click()')
    page.wait_for_timeout(1000)
    
    # Check for audio button (Play audio)
    texts = _get_semantic_text(page)
    audio_found = any('audio' in text.lower() or 'ಶಬ್ದ' in text for text in texts)
    assert audio_found, f"Audio button not found in: {texts}"
    
    # Try to click audio button (no error = pass)
    page.evaluate('''
        () => {
            const semantics = document.querySelectorAll('flt-semantics[role="button"]');
            for (const sem of semantics) {
                if (sem.textContent.includes('audio') || sem.textContent.includes('Play')) {
                    sem.click();
                }
            }
        }
    ''')
    # No error = pass
