/* Only verified, publication-approved content belongs in this data object.
 * Keep photos local to this folder and inspect them before publication.
 * Empty optional sections remain hidden instead of implying unknown facts.
 */
const wagon = {
  photos: [
  {
    "src": "photos/01-front-three-quarter.webp",
    "group": "overview",
    "caption": "The wagon in autumn sunshine",
    "alt": "Front three-quarter view of the grey Acura wagon beneath autumn trees."
  },
  {
    "src": "photos/02-side-profile.webp",
    "group": "overview",
    "caption": "The long-roof profile",
    "alt": "Passenger-side profile of the wagon in a parking area."
  },
  {
    "src": "photos/03-rear-three-quarter.webp",
    "group": "overview",
    "caption": "Rear three-quarter view",
    "alt": "Rear passenger-side three-quarter view, with visible body scuffs."
  },
  {
    "src": "photos/04-front.webp",
    "group": "overview",
    "caption": "Front view",
    "alt": "Front grille, headlights, and bumper; license plate masked."
  },
  {
    "src": "photos/05-rear.webp",
    "group": "overview",
    "caption": "Rear view",
    "alt": "Rear hatch and dual exhaust outlets; license plates masked."
  },
  {
    "src": "photos/06-roof.webp",
    "group": "overview",
    "caption": "Roof rails and sunroof",
    "alt": "Overhead view of roof rails and closed glass sunroof."
  },
  {
    "src": "photos/07-front-seats.webp",
    "group": "overview",
    "caption": "Front cabin",
    "alt": "Front seats, steering wheel, and center console viewed through the open driver door."
  },
  {
    "src": "photos/08-rear-seats.webp",
    "group": "overview",
    "caption": "Rear seats",
    "alt": "Black leather rear seating with visible creasing."
  },
  {
    "src": "photos/09-cockpit.webp",
    "group": "details",
    "caption": "Behind the wheel",
    "alt": "Steering wheel, instrument panel, center screen, and automatic shifter."
  },
  {
    "src": "photos/23-head-unit-maps.webp",
    "group": "details",
    "caption": "Head unit \u00b7 Google Maps",
    "reviewUrl": "https://www.reddit.com/r/AcuraTSX/comments/1jhsj0p/review_android_screen_upgrade_in_my_2011_tsx/",
    "alt": "Aftermarket head unit displaying Google Maps through Android Auto."
  },
  {
    "src": "photos/24-head-unit-camera.webp",
    "group": "details",
    "caption": "Head unit \u00b7 Rear-view camera",
    "alt": "Aftermarket head unit displaying the rear-view camera, with a background-car plate masked."
  },
  {
    "src": "photos/10-cargo.webp",
    "group": "overview",
    "caption": "Cargo space, cover in place",
    "alt": "Open cargo area with its retractable cover extended."
  },
  {
    "src": "photos/11-spare.webp",
    "group": "details",
    "caption": "Under the cargo floor",
    "alt": "Spare tire beneath the lifted cargo floor."
  },
  {
    "src": "photos/12-engine.webp",
    "group": "details",
    "caption": "Under the hood",
    "alt": "Engine bay showing the four-cylinder engine and battery."
  },
  {
    "src": "photos/13-rocker-detail.webp",
    "group": "blemishes",
    "caption": "Lower-body wear: one side",
    "alt": "Closeup of scuffing and rust on a lower rocker-panel area near a wheel."
  },
  {
    "src": "photos/14-rocker-detail.webp",
    "group": "blemishes",
    "caption": "Lower-body wear: other side",
    "alt": "Closeup of visible rust and paint deterioration on another lower rocker-panel area."
  },
  {
    "src": "photos/15-seat-wear.webp",
    "group": "blemishes",
    "caption": "Seat upholstery wear",
    "alt": "Closeup of torn upholstery along the front seat bolster."
  },
  {
    "src": "photos/16-body-scuffs.webp",
    "group": "blemishes",
    "caption": "Wheel-arch scuffs",
    "alt": "Closeup of scuffs above a rear wheel and tire sidewall."
  },
  {
    "src": "photos/17-odometer.webp",
    "group": "details",
    "caption": "132,113 miles \u00b7 November 7, 2026",
    "alt": "Dashboard odometer reading 132113 miles, photographed November 7, 2026."
  },
  {
    "src": "photos/18-front-driver-wheel.webp",
    "group": "details",
    "caption": "Front passenger-side wheel",
    "alt": "Close-up of the front passenger-side alloy wheel and tire, with visible wheel scuffs and lower-body wear."
  },
  {
    "src": "photos/19-rear-driver-wheel.webp",
    "group": "details",
    "caption": "Rear passenger-side wheel",
    "alt": "Close-up of the rear passenger-side alloy wheel and tire."
  },
  {
    "src": "photos/20-front-passenger-wheel.webp",
    "group": "details",
    "caption": "Front driver-side wheel",
    "alt": "Close-up of the front driver-side alloy wheel and tire, with visible scuffs on the wheel rim and spokes."
  },
  {
    "src": "photos/21-rear-passenger-wheel.webp",
    "group": "details",
    "caption": "Rear driver-side wheel",
    "alt": "Close-up of the rear driver-side alloy wheel and tire."
  },
  {
    "src": "photos/22-spare-wheel.webp",
    "group": "details",
    "caption": "Spare wheel",
    "alt": "The compact spare wheel and tire standing outside the open cargo area."
  },
  {
    "src": "photos/25-biggest-fans.webp",
    "group": "fans",
    "caption": "One of the wagon’s biggest fans",
    "alt": "A smiling child sitting in the parked wagon’s driver seat with hands on the steering wheel."
  },
  {
    "src": "photos/26-car-wash.webp",
    "group": "fans",
    "caption": "At the car wash",
    "alt": "Two children washing the parked wagon with colorful water toys."
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
// Keep the viewer's next/previous order aligned with the grouped gallery.
const galleryPhotos = ['overview', 'details', 'blemishes', 'fans'].flatMap(group =>
  wagon.photos.filter(photo => photo.group === group)
);
const viewer = document.getElementById('photo-viewer');
let selectedPhoto = 0;
function showPhoto(index) {
  selectedPhoto = (index + galleryPhotos.length) % galleryPhotos.length;
  const photo = galleryPhotos[selectedPhoto];
  const image = document.getElementById('full-photo');
  image.src = photo.full || photo.src;
  image.alt = photo.alt;
  document.getElementById('photo-caption').textContent = photo.caption || photo.alt;
  document.getElementById('photo-position').textContent = `${selectedPhoto + 1} / ${galleryPhotos.length}`;
  if (!viewer.open) viewer.showModal();
}
if (galleryPhotos.length) {
  galleryPhotos.forEach((photo, index) => {
    const fig = el('figure');
    const button = el('button');
    button.type = 'button';
    button.setAttribute('aria-label', `Enlarge photograph: ${photo.alt}`);
    const image = el('img');
    // Small redacted thumbnails load immediately; the viewer uses the full photo.
    image.loading = 'eager';
    image.src = photo.src.replace('photos/', 'thumbnails/');
    image.alt = photo.alt;
    button.append(image);
    button.addEventListener('click', () => showPhoto(index));
    fig.append(button);
    if (photo.caption) {
      const caption = el('figcaption', photo.caption);
      if (photo.reviewUrl) {
        const link = el('a', 'Read my installation review');
        link.href = photo.reviewUrl;
        caption.append(document.createTextNode(' · '), link);
      }
      fig.append(caption);
    }
    document.getElementById(`gallery-${photo.group}`).append(fig);
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
