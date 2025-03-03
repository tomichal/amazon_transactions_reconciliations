# Summary

Credit card statement for amazon transactions only shows something like "amazon.com ... order number ..." and no details what you bought, or if it was even from your account.

Amazon also doesn't seem to make it easy to programmatically (via an api call, scraping, or data export) get a list of your orders. 

Instead then, you can take screenshots of your amazon orders from the orders listing pages, use OCR to parse them, then parse the credit card transactions out of the credit card statement PDF and create a spreadsheet that can flag any credit card transactions for amazon orders that are not in your orders list. 