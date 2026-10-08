export default class EVGC {
    static records = new Set();

    static addEvent(type, node, handler, options = {}) {
        node.addEventListener(type, handler, options);

        const record = {
            node,
            type,
            handler,
            capture: options.capture ?? false,
        };
        EVGC.records.add(record);
        return record;
    }

    static rmEvent(type, node, handler, options = {}) {
        const capture = options.capture ?? false;
        node.removeEventListener(type, handler, { capture });

        for (const r of EVGC.records) {
            if (r.node === node && r.type === type
                && r.handler === handler && r.capture === capture) {
                EVGC.records.delete(r);
                break;
            }
        }
    }

    static freeAll() {
        for (const r of EVGC.records) {
            r.node.removeEventListener(r.type, r.handler, { capture: r.capture });
        }
        EVGC.records.clear();
    }

    static freeNode(node) {
        for (const r of EVGC.records) {
            if (r.node === node) {
                r.node.removeEventListener(r.type, r.handler, { capture: r.capture });
                EVGC.records.delete(r);
            }
        }
    }
}