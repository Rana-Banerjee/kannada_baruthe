import pytest, json
from playwright.sync_api import sync_playwright

BASE_URL = "http://localhost:8080"
LESSON_FILE = "data/lessons/lesson_01.json"

@pytest.fixture(scope="session")
def lesson_data():
    with open(LESSON_FILE) as f: return json.load(f)

@pytest.fixture(scope="session")
def browser_context():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        ctx = browser.new_context(viewport={'width': 1920, 'height': 1080})
        yield ctx
        browser.close()

@pytest.fixture
def page(browser_context):
    page = browser_context.new_page()
    yield page
    page.close()

def _enable_flutter_accessibility(page):
    """Enable Flutter's accessibility mode to expose semantic elements"""
    page.evaluate('() => document.querySelector("flt-semantics-placeholder")?.click()')
    page.wait_for_timeout(1000)

def go_home(page):
    """Navigate to home screen and enable Flutter accessibility"""
    # Go to the URL fresh
    page.goto(BASE_URL)
    page.wait_for_timeout(4000)
    
    # Enable Flutter accessibility - this exposes semantic elements
    page.evaluate('''
        () => {
            const el = document.querySelector("flt-semantics-placeholder");
            if (el) {
                el.scrollIntoViewIfNeeded();
                el.click();
            }
        }
    ''')
    page.wait_for_timeout(2000)
    
    # Verify we have semantic elements
    semantic_count = page.locator('flt-semantics').count()
    if semantic_count == 0:
        # Try one more time
        page.evaluate('() => document.querySelector("flt-semantics-placeholder")?.click()')
        page.wait_for_timeout(2000)

def _click_button_by_text(page, text):
    """Click a Flutter button by its text content using semantic elements"""
    page.evaluate(f'''
        () => {{
            const buttons = document.querySelectorAll('flt-semantics[role="button"]');
            for (const btn of buttons) {{
                if (btn.textContent.includes("{text}")) {{
                    btn.click();
                    return true;
                }}
            }}
            return false;
        }}
    ''')
    page.wait_for_timeout(500)

def _get_semantic_text(page):
    """Get all semantic element texts for debugging"""
    semantics = page.locator('flt-semantics').all()
    texts = []
    for sem in semantics:
        text = sem.inner_text() if sem.inner_text() else ''
        if text.strip():
            texts.append(text)
    return texts
