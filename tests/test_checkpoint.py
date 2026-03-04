from conftest import go_home, _get_semantic_text

def test_restart_clears_checkpoint(page):                # AC6.3
    go_home(page)
    
    # Start lesson
    page.evaluate('''
        () => {
            const buttons = document.querySelectorAll('flt-semantics[role="button"]');
            for (const btn of buttons) {
                if (btn.textContent.includes('Start Lesson')) btn.click();
            }
        }
    ''')
    page.wait_for_timeout(2000)
    
    # Enable accessibility and complete one exercise
    page.evaluate('() => document.querySelector("flt-semantics-placeholder")?.click()')
    page.wait_for_timeout(1000)
    
    # Click Apple tile (correct answer)
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
    
    page.evaluate('''
        () => {
            const buttons = document.querySelectorAll('flt-semantics[role="button"]');
            for (const btn of buttons) {
                if (btn.textContent.includes('Continue') || btn.textContent.includes('ಮುಂದೆ')) btn.click();
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
    # Should see Resume and Restart buttons
    has_restart = any('Restart' in text for text in texts)
    assert has_restart, f"Restart button not found in: {texts}"
    
    # Click Restart
    page.evaluate('''
        () => {
            const buttons = document.querySelectorAll('flt-semantics[role="button"]');
            for (const btn of buttons) {
                if (btn.textContent.includes('Restart')) btn.click();
            }
        }
    ''')
    page.wait_for_timeout(2000)
    
    # Check progress is back to 1
    page.evaluate('() => document.querySelector("flt-semantics-placeholder")?.click()')
    page.wait_for_timeout(1000)
    
    texts = _get_semantic_text(page)
    progress_found = any('1 /' in text for text in texts)
    assert progress_found, f"Progress should be 1/10, not found in: {texts}"

def test_resume_restores_position(page):                 # AC6.1, AC2.1
    go_home(page)
    
    # Start lesson
    page.evaluate('''
        () => {
            const buttons = document.querySelectorAll('flt-semantics[role="button"]');
            for (const btn of buttons) {
                if (btn.textContent.includes('Start Lesson')) btn.click();
            }
        }
    ''')
    
    # Complete 2 exercises
    for i in range(2):
        page.wait_for_timeout(1500)
        page.evaluate('() => { const p = document.querySelector("flt-semantics-placeholder"); if (p) p.click(); }')
        page.wait_for_timeout(500)
        
        # Click Apple tile (correct answer)
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
        
        page.evaluate('''
            () => {
                const buttons = document.querySelectorAll('flt-semantics[role="button"]');
                for (const btn of buttons) {
                    if (btn.textContent.includes('Continue') || btn.textContent.includes('ಮುಂದೆ')) btn.click();
                }
            }
        ''')
        page.wait_for_timeout(500)
    
    # Go back to home
    page.go_back()
    page.wait_for_timeout(2000)
    
    # Enable accessibility
    page.evaluate('() => document.querySelector("flt-semantics-placeholder")?.click()')
    page.wait_for_timeout(1000)
    
    # Click Resume
    page.evaluate('''
        () => {
            const buttons = document.querySelectorAll('flt-semantics[role="button"]');
            for (const btn of buttons) {
                if (btn.textContent.includes('Resume')) btn.click();
            }
        }
    ''')
    page.wait_for_timeout(2000)
    
    # Check progress shows 3 (after completing 2 exercises)
    page.evaluate('() => document.querySelector("flt-semantics-placeholder")?.click()')
    page.wait_for_timeout(1000)
    
    texts = _get_semantic_text(page)
    # Should show progress 3 (exercise 3 is current)
    progress_found = any('3 /' in text for text in texts)
    assert progress_found, f"Progress should be 3/10, not found in: {texts}"
