// Inner SVG markup (24x24, stroke=currentColor). Digunakan lewat set:html.
export const featureIcons: Record<string, string> = {
  check:
    '<rect x="3.5" y="3.5" width="17" height="17" rx="4"/><path d="M8 12.2l2.8 2.8 5.2-5.6"/>',
  list:
    '<circle cx="6" cy="6" r="1.3" fill="currentColor" stroke="none"/><line x1="10" y1="6" x2="20" y2="6"/><circle cx="6" cy="12" r="1.3" fill="currentColor" stroke="none"/><line x1="10" y1="12" x2="20" y2="12"/><circle cx="6" cy="18" r="1.3" fill="currentColor" stroke="none"/><line x1="10" y1="18" x2="16" y2="18"/>',
  flame:
    '<path d="M12 3c1.2 2.6-1.6 4.1-1.6 6.3A3.6 3.6 0 0 0 14 12.9c0-.9-.3-1.7-.8-2.4 1.3.8 2 2 2 3.5a4.8 4.8 0 0 1-9.6 0C5.6 9.6 8.6 6.2 12 3z"/>',
  widget:
    '<rect x="3.5" y="3.5" width="7" height="7" rx="2"/><rect x="13.5" y="3.5" width="7" height="7" rx="2"/><rect x="3.5" y="13.5" width="7" height="7" rx="2"/><rect x="13.5" y="13.5" width="7" height="7" rx="2"/>',
  chart:
    '<line x1="4" y1="20" x2="4" y2="12"/><line x1="10" y1="20" x2="10" y2="7"/><line x1="16" y1="20" x2="16" y2="14.5"/><line x1="2.5" y1="20" x2="21" y2="20"/>',
  archive:
    '<path d="M3.5 7.5V19A1.5 1.5 0 0 0 5 20.5h14a1.5 1.5 0 0 0 1.5-1.5V7.5"/><path d="M3 7.5h18l-1.6-3.6a1 1 0 0 0-.9-.6H6.5a1 1 0 0 0-.9.6z"/><line x1="12" y1="11" x2="12" y2="16"/><path d="M9.2 13.4L12 16.2l2.8-2.8"/>',
};

export const sunSvg =
  '<circle cx="12" cy="12" r="4"/><path d="M12 2.5v2M12 19.5v2M2.5 12h2M19.5 12h2M5.2 5.2l1.4 1.4M17.4 17.4l1.4 1.4M18.8 5.2l-1.4 1.4M6.6 17.4l-1.4 1.4"/>';

export const moonSvg =
  '<path d="M20 13.4A8 8 0 1 1 10.6 4a6.4 6.4 0 0 0 9.4 9.4z"/>';

export const chevronDownSvg = '<path d="M6 9l6 6 6-6"/>';