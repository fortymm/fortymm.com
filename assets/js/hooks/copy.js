export const Copy = {
    mounted() {
        let { to } = this.el.dataset;
        this.el.addEventListener("click", (ev) => {
            ev.preventDefault();
            console.log(this.el.dataset)
            let text = this.el.dataset.text;
            navigator.clipboard.writeText(text).then(() => {
                const originalText = this.el.innerHTML;
                this.el.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                                       <path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5" />
                                    </svg>`;


                setTimeout(() => {
                    this.el.innerHTML = originalText;
                }, 2000)
            })
        });
    },
};
