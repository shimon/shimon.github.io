/* Only verified, publication-approved content belongs in this data object.
 * Keep photos local to this folder and inspect them before publication.
 * Empty optional sections remain hidden instead of implying unknown facts.
 */
const wagon = {
  photos: [
  {
    "src": "photos/01-front-three-quarter.webp",
    "caption": "The wagon in autumn sunshine",
    "alt": "Front three-quarter view of the grey Acura wagon beneath autumn trees."
  },
  {
    "src": "photos/02-side-profile.webp",
    "caption": "The long-roof profile",
    "alt": "Passenger-side profile of the wagon in a parking area."
  },
  {
    "src": "photos/03-rear-three-quarter.webp",
    "caption": "Rear three-quarter view",
    "alt": "Rear passenger-side three-quarter view, with visible body scuffs."
  },
  {
    "src": "photos/04-front.webp",
    "caption": "Front view",
    "alt": "Front grille, headlights, and bumper; license plate masked."
  },
  {
    "src": "photos/05-rear.webp",
    "caption": "Rear view",
    "alt": "Rear hatch and dual exhaust outlets; license plates masked."
  },
  {
    "src": "photos/06-roof.webp",
    "caption": "Roof rails and sunroof",
    "alt": "Overhead view of roof rails and closed glass sunroof."
  },
  {
    "src": "photos/07-front-seats.webp",
    "caption": "Front cabin",
    "alt": "Front seats, steering wheel, and center console viewed through the open driver door."
  },
  {
    "src": "photos/08-rear-seats.webp",
    "caption": "Rear seats",
    "alt": "Black leather rear seating with visible creasing."
  },
  {
    "src": "photos/09-cockpit.webp",
    "caption": "Behind the wheel",
    "alt": "Steering wheel, instrument panel, center screen, and automatic shifter."
  },
  {
    "src": "photos/10-cargo.webp",
    "caption": "Cargo space, cover in place",
    "alt": "Open cargo area with its retractable cover extended."
  },
  {
    "src": "photos/11-spare.webp",
    "caption": "Under the cargo floor",
    "alt": "Spare tire beneath the lifted cargo floor."
  },
  {
    "src": "photos/12-engine.webp",
    "caption": "Under the hood",
    "alt": "Engine bay showing the four-cylinder engine and battery."
  },
  {
    "src": "photos/13-rocker-detail.webp",
    "caption": "Lower-body wear: one side",
    "alt": "Closeup of scuffing and rust on a lower rocker-panel area near a wheel."
  },
  {
    "src": "photos/14-rocker-detail.webp",
    "caption": "Lower-body wear: other side",
    "alt": "Closeup of visible rust and paint deterioration on another lower rocker-panel area."
  },
  {
    "src": "photos/15-seat-wear.webp",
    "caption": "Seat upholstery wear",
    "alt": "Closeup of torn upholstery along the front seat bolster."
  },
  {
    "src": "photos/16-body-scuffs.webp",
    "caption": "Wheel-arch scuffs",
    "alt": "Closeup of scuffs above a rear wheel and tire sidewall."
  },
  {
    "src": "photos/17-odometer.webp",
    "caption": "132,113 miles \u00b7 November 7, 2026",
    "alt": "Dashboard odometer reading 132113 miles, photographed November 7, 2026."
  }
],
  story: [], // Plain-text paragraphs from the owner.
  history: [], // Plain-text, source-checked service and condition disclosures.
  facts: [], // {label: 'Mileage', value: 'Confirmed reading and date'}
  saleDetails: '',
  contactEmail: ''
};
const el = (tag, text, className) => { const node=document.createElement(tag); if(text)node.textContent=text; if(className)node.className=className; return node; };
const reveal = id => {document.getElementById(id).hidden=false;};
for(const fact of wagon.facts){const row=el('div');row.append(el('dt',fact.label),el('dd',fact.value));document.querySelector('.facts').append(row);}
const viewer = document.getElementById('photo-viewer');
let selectedPhoto = 0;
function showPhoto(index) {
  selectedPhoto = (index + wagon.photos.length) % wagon.photos.length;
  const photo = wagon.photos[selectedPhoto];
  const image = document.getElementById('full-photo');
  image.src = photo.full || photo.src;
  image.alt = photo.alt;
  document.getElementById('photo-caption').textContent = photo.caption || photo.alt;
  document.getElementById('photo-position').textContent = `${selectedPhoto + 1} / ${wagon.photos.length}`;
  if (!viewer.open) viewer.showModal();
}
if (wagon.photos.length) {
  const photo = wagon.photos[0];
  const hero = el('img');
  hero.src = photo.src;
  hero.alt = photo.alt;
  hero.fetchPriority = 'high';
  if (photo.position) hero.style.objectPosition = photo.position;
  document.getElementById('hero-media').replaceChildren(hero);
  wagon.photos.forEach((photo, index) => {
    const fig = el('figure');
    const button = el('button');
    button.type = 'button';
    button.setAttribute('aria-label', `Enlarge photograph: ${photo.alt}`);
    const image = el('img');
    image.src = photo.src;
    image.alt = photo.alt;
    image.loading = 'lazy';
    image.decoding = 'async';
    button.append(image);
    button.addEventListener('click', () => showPhoto(index));
    fig.append(button);
    if (photo.caption) fig.append(el('figcaption', photo.caption));
    document.getElementById('gallery').append(fig);
  });
  reveal('gallery-section');
}
if (viewer) {
  document.getElementById('close-photo').addEventListener('click', () => viewer.close());
  document.getElementById('previous-photo').addEventListener('click', () => showPhoto(selectedPhoto - 1));
  document.getElementById('next-photo').addEventListener('click', () => showPhoto(selectedPhoto + 1));
  viewer.addEventListener('keydown', event => {
    if (event.key === 'ArrowRight') { event.preventDefault(); showPhoto(selectedPhoto + 1); }
    if (event.key === 'ArrowLeft') { event.preventDefault(); showPhoto(selectedPhoto - 1); }
  });
}
for(const [key,id,section] of [['story','story-copy','story-section'],['history','history','history-section']]){if(wagon[key].length){wagon[key].forEach(text=>document.getElementById(id).append(el('p',text)));reveal(section);}}
if(wagon.contactEmail&&wagon.saleDetails){document.getElementById('sale-details').textContent=wagon.saleDetails;document.getElementById('contact').href='mailto:'+wagon.contactEmail+'?subject='+encodeURIComponent('2011 Acura TSX wagon');reveal('contact-section');}
